# frozen_string_literal: true

describe 'Booking', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_rich_text_templates) }
  let(:user) { create(:user, :manager, organisation: organisation) }
  let(:home) { create(:home, organisation: organisation) }
  let(:tenant) { create(:tenant, organisation: organisation) }
  let!(:tarifs) { create_list(:tarif, 2, home: home) }
  let(:new_booking_path) do
    new_public_booking_path(booking: { home_id: home.id, occupancy_attributes:
      { begins_at: booking.occupancy.begins_at.iso8601, ends_at: booking.occupancy.ends_at.iso8601 } })
  end
  let(:booking) do
    build(:booking,
          organisation: organisation,
          home: home, tenant: nil,
          skip_infer_transition: false,
          committed_request: false,
          notifications_enabled: true)
  end

  it 'flows through happy path' do
    create_request
    confirm_request
    signin(user, user.password)
    visit_booking
    accept_booking
    commit_request
    define_tarifs
    create_contract
    create_deposit
    confirm_booking
    perform_booking
    set_usages
    create_invoice
    finalize_booking
    check_booking
  end

  def create_request
    visit new_booking_path
    fill_in 'booking_email', with: tenant.email
    check 'booking_accept_conditions'
    submit_form
    expect(page).to have_content(I18n.t('flash.public.bookings.create.notice'))
    @booking = Booking.last
  end

  def confirm_request
    visit edit_public_booking_path(id: @booking)
    fill_in 'booking_approximate_headcount', with: booking.approximate_headcount
    fill_in 'booking_tenant_organisation', with: booking.tenant_organisation
    find('#booking_purpose_id').select(booking.purpose.title)
    choose 'booking_committed_request_false'
    submit_form
    expect(page).to have_content(I18n.t('flash.public.bookings.update.notice'))
  end

  def visit_booking
    visit manage_bookings_path
    click_on @booking.ref
    expect(page).to have_content(@booking.tenant.email)
  end

  def accept_booking
    visit manage_booking_path(@booking, org: nil)
    click_on :accept
    click_on :postpone_deadline
  end

  def commit_request
    visit edit_public_booking_path(id: @booking)
    click_on :commit_request
  end

  def define_tarifs
    visit manage_booking_path(@booking, org: nil)
    find('.checklist li:nth-child(1) a').click
    tarifs.each do |tarif|
      expect(page).to have_content(tarif.label)
    end
    find_all('input[type="checkbox"]:not(:checked)').each(&:check)
    submit_form
  end

  def create_contract
    visit manage_booking_path(@booking, org: nil)
    find('.checklist li:nth-child(2) a').click
    visit new_manage_booking_contract_path(@booking, org: nil)
    submit_form
    find('table tbody tr:nth-child(1) td:nth-child(1) a').click
  end

  def create_deposit
    visit manage_booking_path(@booking, org: nil)
    find('.checklist li:nth-child(3) a').click
    submit_form
  end

  def confirm_booking
    visit manage_booking_path(@booking, org: nil)
    click_on :email_contract_and_deposit
    click_on :mark_contract_signed
  end

  def perform_booking
    visit manage_booking_path(@booking, org: nil)
    click_on :allowed_transitions
    click_on :upcoming_soon
    click_on :allowed_transitions
    click_on :active
    click_on :allowed_transitions
    click_on :past
  end

  def set_usages
    visit manage_booking_path(@booking, org: nil)
    find('.checklist li:nth-child(1) a').click
    # page.driver.browser.navigate.refresh
    find_all('input[type="number"]').each do |usage_field|
      usage_field.fill_in with: 22
    end
    submit_form
  end

  def create_invoice
    visit manage_booking_path(@booking, org: nil)
    find('.checklist li:nth-child(2) a').click
    submit_form
  end

  def finalize_booking
    visit manage_booking_path(@booking, org: nil)
    click_on :email_invoice
    click_on :postpone_deadline
    visit manage_booking_invoices_path(@booking, org: nil)
    click_on I18n.t(:add_record, model_name: Payment.model_name.human)
    submit_form
  end

  def check_booking
    expected_notifications = %w[payment_due_notification payment_confirmation_notification upcoming_notification
                                upcoming_soon_notification awaiting_contract_notification
                                definitive_request_notification manage_definitive_request_notification
                                provisional_request_notification open_request_notification
                                manage_new_booking_notification unconfirmed_request_notification]
    expected_transitions = %w[unconfirmed_request open_request provisional_request definitive_request
                              awaiting_contract upcoming upcoming_soon active past payment_due completed]
    expect(@booking.notifications.map { |notification| notification.rich_text_template.key })
      .to contain_exactly(*expected_notifications)
    expect(@booking.booking_transitions.ordered.map(&:to_state)).to contain_exactly(*expected_transitions)
  end
end
