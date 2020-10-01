# frozen_string_literal: true

describe 'Booking', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_markdown_templates) }
  let(:user) { create(:user, :manager, organisation: organisation) }
  let(:home) { create(:home, organisation: organisation) }
  let!(:tarifs) { create_list(:tarif, 2, home: home) }
  let!(:booking) do
    create(:booking,
           organisation: organisation,
           home: home,
           skip_automatic_transition: false,
           committed_request: false,
           notifications_enabled: true)
  end

  it 'flows through happy path' do
    signin(user, user.password)
    visit_booking
    accept_booking
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

  def visit_booking
    visit manage_bookings_path
    click_on booking.ref
    expect(page).to have_content(booking.tenant.email)
  end

  def accept_booking
    visit manage_booking_path(booking, org: nil)
    click_on :allowed_transitions
    click_on :open_request
    click_on :accept
    click_on :postpone_deadline
    click_on :commit_request
  end

  def define_tarifs
    visit manage_booking_path(booking, org: nil)
    find('.checklist li:nth-child(1) a').click
    tarifs.each do |tarif|
      expect(page).to have_content(tarif.label)
    end
    find_all('input[type="checkbox"]:not(:checked)').each(&:check)
    click_on :commit
  end

  def create_contract
    visit manage_booking_path(booking, org: nil)
    find('.checklist li:nth-child(2) a').click
    visit new_manage_booking_contract_path(booking, org: nil)
    click_on :commit
    find('table tbody tr:nth-child(1) td:nth-child(1) a').click
  end

  def create_deposit
    visit manage_booking_path(booking, org: nil)
    find('.checklist li:nth-child(3) a').click
    within('#dropdownInvoiceTypes') do
      find('#dropdownInvoiceTypesButton').click
      click_on Invoices::Deposit.model_name.human
    end
    visit new_manage_booking_invoice_path(booking, org: nil, invoice: { type: Invoices::Deposit })
    click_on :commit
  end

  def confirm_booking
    visit manage_booking_path(booking, org: nil)
    click_on :email_contract_and_deposit
    click_on :mark_contract_signed
  end

  def perform_booking
    visit manage_booking_path(booking, org: nil)
    click_on :allowed_transitions
    click_on :upcoming_soon
    click_on :allowed_transitions
    click_on :active
    click_on :allowed_transitions
    click_on :past
  end

  def set_usages
    visit manage_booking_path(booking, org: nil)
    find('.checklist li:nth-child(1) a').click
    # page.driver.browser.navigate.refresh
    find_all('input[type="number"]').each do |usage_field|
      usage_field.fill_in with: 22
    end
    click_on :commit
  end

  def create_invoice
    visit manage_booking_path(booking, org: nil)
    find('.checklist li:nth-child(2) a').click
    within('#dropdownInvoiceTypes') do
      find('#dropdownInvoiceTypesButton').click
      click_on Invoices::Invoice.model_name.human
    end
    click_on :commit
  end

  def finalize_booking
    visit manage_booking_path(booking, org: nil)
    click_on :email_invoice
    click_on :postpone_deadline
    visit manage_booking_invoices_path(booking, org: nil)
    click_on I18n.t(:add_record, model_name: Payment.model_name.human)
    click_on :commit
  end

  def check_booking
    expected_notifications = %w[payment_due payment upcoming awaiting_contract
                                definitive_request provisional_request open_request
                                manage_new_booking_mail unconfirmed_request]
    expected_transitions = %w[unconfirmed_request open_request provisional_request definitive_request
                              awaiting_contract upcoming upcoming_soon active past payment_due completed]
    # booking.reload
    expect(booking.notifications.map { |notification| notification.markdown_template.key })
      .to contain_exactly(*expected_notifications)
    expect(booking.booking_transitions.ordered.map(&:to_state))
      .to contain_exactly(*expected_transitions)
  end
end
