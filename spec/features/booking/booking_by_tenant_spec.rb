# frozen_string_literal: true

describe 'Booking by tenant', :devise do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:org) { organisation.to_param }
  let(:organisation_user) { create(:organisation_user, :manager, organisation:) }
  let(:user) { organisation_user.user }
  let(:home) { create(:home, organisation:) }
  let(:tenant) { create(:tenant, organisation:) }
  let(:deposit_tarifs) do
    create(:tarif, organisation:, tarif_group: 'Akontorechnung',
                   associated_types: %i[deposit offer contract])
  end

  let(:invoice_tarifs) do
    create_list(:tarif, 2, organisation:, tarif_group: 'Übernachtungen',
                           associated_types: %i[invoice offer contract])
  end

  let!(:tarifs) { [deposit_tarifs, invoice_tarifs].flatten }
  let!(:booking_question) do
    create(:booking_question, organisation:, required: true, type: BookingQuestions::Integer.to_s,
                              tenant_mode: :provisional_editable, booking_agent_mode: :not_visible)
  end

  let(:new_booking_path) do
    new_public_booking_path(booking: { home_id: home.id, begins_at: booking.begins_at.iso8601,
                                       ends_at: booking.ends_at.iso8601 })
  end

  let(:booking) do
    begins_at = Time.zone.local(Time.zone.now.year + 1, 2, 28, 8)
    build(:booking, begins_at:, ends_at: begins_at + 1.week + 4.hours + 15.minutes,
                    organisation:, home:, tenant: nil, committed_request: false, notifications_enabled: true)
  end

  let(:expected_notifications) do
    %w[email_invoice_notification payment_confirmation_notification
       upcoming_notification operator_upcoming_notification operator_upcoming_notification
       operator_upcoming_soon_notification operator_upcoming_soon_notification operator_upcoming_soon_notification
       upcoming_soon_notification email_contract_notification past_notification
       definitive_request_notification manage_definitive_request_notification
       provisional_request_notification open_request_notification contract_signed_notification
       manage_new_booking_notification unconfirmed_request_notification completed_notification
       operator_email_contract_notification operator_email_contract_notification operator_email_contract_notification
       operator_email_invoice_notification operator_payment_confirmation_notification
       operator_contract_signed_notification operator_contract_signed_notification
       operator_contract_signed_notification]
  end

  let(:expected_transitions) do
    %w[unconfirmed_request open_request provisional_request definitive_request
       awaiting_contract upcoming upcoming_soon active past payment_due completed]
  end

  before do
    OperatorResponsibility.responsibilities.keys.map do |responsibility|
      create(:operator_responsibility, organisation:, responsibility:,
                                       assigning_conditions: [BookingConditions::Always.new])
    end
  end

  it 'flows through happy path' do # rubocop:disable RSpec/NoExpectationExample,RSpec/ExampleLength
    create_request
    confirm_request
    signin(user, user.password)
    visit_booking
    accept_booking
    commit_request
    choose_tarifs
    create_contract
    create_deposit
    confirm_booking
    bide_booking
    set_usages
    create_invoice
    send_invoice
    finalize_booking
    check_booking
  end

  def fill_request_form(email:, begins_at:, ends_at:, home:)
    # select(home.to_s, from: 'booking_home_id')
    check "booking_occupiable_ids_#{home.id}"
    fill_in 'booking_begins_at_date', with: begins_at.strftime('%d.%m.%Y')
    select(format('%02d:00', begins_at.hour), from: 'booking_begins_at_time')
    fill_in 'booking_ends_at_date', with: ends_at.strftime('%d.%m.%Y')
    select(format('%02d:00', ends_at.hour), from: 'booking_ends_at_time')
    fill_in 'booking_email', with: email
    check 'booking_accept_conditions'
  end

  def create_request
    visit new_booking_path
    fill_request_form(email: tenant.email, begins_at: booking.begins_at, ends_at: booking.ends_at, home: booking.home)
    submit_form
    flash = Rails::Html::FullSanitizer.new.sanitize(I18n.t('flash.public.bookings.create.notice',
                                                           email: tenant.email,
                                                           mailto_organisation: organisation.email))
    expect(page).to have_content(flash)
    @booking = Booking.last
  end

  def confirm_request # rubocop:disable Metrics/MethodLength
    visit edit_public_booking_path(id: @booking.token)
    fill_in 'booking_approximate_headcount', with: booking.approximate_headcount
    fill_in 'booking_tenant_organisation', with: booking.tenant_organisation
    choose 'booking_committed_request_false'
    choose 'booking[booking_category_id]', option: booking.category.id
    fill_in 'booking_purpose_description', with: booking.purpose_description
    submit_form
    expect(page).to have_content(I18n.t('flash.actions.update.alert', resource_name: Booking.model_name.human))
    fill_in booking_question.label, with: '10'
    submit_form
    expect(page).to have_content(I18n.t('flash.public.bookings.update.notice'))
  end

  def visit_booking
    visit manage_bookings_path
    click_on @booking.ref
    expect(page).to have_content(@booking.tenant.email)
  end

  def accept_booking
    visit manage_booking_path(@booking, org:)
    click_button BookingActions::Accept.t(:label)
    click_button BookingActions::PostponeDeadline.t(:label)
  end

  def commit_request
    visit public_booking_path(id: @booking.token)
    click_button BookingActions::CommitRequest.t(:label)
    page.driver.browser.switch_to.alert.accept
  end

  def choose_tarifs
    visit manage_booking_path(@booking, org:)
    find('.checklist a[aria-label="tarifs_chosen"]').click
    tarifs.each do |tarif|
      expect(page).to have_content(tarif.label)
    end
    find_all('input[type="checkbox"]:not(:checked)').each(&:check)
    submit_form
  end

  def create_contract
    visit manage_booking_path(@booking, org:)
    find('.checklist a[aria-label="contract_created"]').click
    visit new_manage_booking_contract_path(@booking, org:)
    submit_form
    # find('table tbody tr:nth-child(1) td:nth-child(1) a').click
  end

  def create_deposit
    visit manage_booking_path(@booking, org:)
    find('.checklist a[aria-label="deposit_created"]').click
    submit_form
    expect(page).to have_content(I18n.t('flash.actions.create.notice',
                                        resource_name: Invoices::Deposit.model_name.human))
  end

  def confirm_booking
    visit manage_booking_path(@booking, org:)
    click_button BookingActions::EmailContract.translate(:label_with_invoice)
    click_button I18n.t('manage.notifications.form.deliver')
    visit manage_booking_path(@booking, org:)
    click_on BookingActions::MarkContractSigned.label
    click_on BookingActions::MarkContractSigned.label # confirm
  end

  def bide_booking
    visit manage_booking_path(@booking, org:)
    visit manage_booking_path(@booking, org:) # capybara issue
    click_on :allowed_transitions
    click_on :upcoming_soon
    click_on :allowed_transitions
    click_on :active
    click_on :allowed_transitions
    click_on :past
  end

  def set_usages
    visit manage_booking_path(@booking, org:)
    find('.checklist li:nth-child(1) a').click
    # page.driver.browser.navigate.refresh
    find_all('input[inputmode="numeric"]').each do |usage_field|
      usage_field.fill_in with: 22
    end
    submit_form
  end

  def create_invoice
    visit manage_booking_path(@booking, org:)
    visit manage_booking_path(@booking, org:) # capybara issue

    find('.checklist li:nth-child(2) a').click
    submit_form
  end

  def send_invoice
    visit manage_booking_path(@booking, org:)
    find_all('[name="action"][value="email_invoice"]').first.click
    click_button I18n.t('manage.notifications.form.deliver')
    visit manage_booking_path(@booking, org:)
  end

  def finalize_booking
    find_all('[name="action"][value="postpone_deadline"]').first.click
    visit manage_booking_invoices_path(@booking, org:)
    click_on I18n.t(:add_record, model_name: Payment.model_name.human)
    find_all('[type="submit"]').last.click
  end

  def check_booking
    expect(@booking.notifications.map { |notification| notification.mail_template.key })
      .to match_array(expected_notifications)
    expect(@booking.state_transitions.ordered.map(&:to_state)).to match_array(expected_transitions)
  end

  describe 'check conflicting bookings' do
    before do
      create(:booking, home:, organisation:, begins_at: booking.begins_at, ends_at: booking.ends_at,
                       occupancy_type: :tentative, initial_state: :provisional_request)
    end

    context 'without waitlist_enabled' do
      it 'returns error' do
        visit new_booking_path
        fill_request_form(email: tenant.email, begins_at: booking.begins_at, ends_at: booking.ends_at,
                          home: booking.home)
        submit_form
        expect(page).to have_content(I18n.t('activerecord.errors.messages.occupancy_conflict'))
      end
    end

    context 'with waitlist_enabled' do
      before { organisation.tap { it.booking_state_settings.enable_waitlist = true }.save! }

      it 'returns no error' do
        visit new_booking_path
        fill_request_form(email: tenant.email, begins_at: booking.begins_at, ends_at: booking.ends_at,
                          home: booking.home)
        submit_form
        expect(page).to have_no_content(I18n.t('activerecord.errors.messages.occupancy_conflict'))
      end
    end

    context 'with waitlist_enabled and conflicting booking' do
      let(:conflicting_booking) do
        create(:booking, home:, organisation:, begins_at: booking.begins_at, ends_at: booking.ends_at,
                         occupancy_type: :occupied, initial_state: :upcoming)
      end

      before { organisation.tap { it.booking_state_settings.enable_waitlist = true }.save! }

      it 'returns error' do
        conflicting_booking
        visit new_booking_path
        fill_request_form(email: tenant.email, begins_at: booking.begins_at, ends_at: booking.ends_at,
                          home: booking.home)
        submit_form
        expect(page).to have_content(I18n.t('activerecord.errors.messages.occupancy_conflict'))
      end
    end
  end
end
