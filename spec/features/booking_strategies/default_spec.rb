# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

describe 'Booking', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_markdown_templates) }
  let(:user) { create(:user, organisation: organisation) }
  let(:home) { create(:home, organisation: organisation) }
  let!(:tarifs) { create_list(:tarif, 2, home: home) }
  let!(:booking) do
    create(:booking,
           organisation: organisation,
           home: home,
           skip_automatic_transition: false,
           committed_request: false,
           messages_enabled: true)
  end

  before do
    allow(Organisation).to receive(:current).and_return(organisation)
  end

  it do
    login_as(user, scope: :user)
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
    visit manage_booking_path(booking)
    click_on :allowed_transitions
    click_on :open_request
    click_on :accept
    click_on :postpone_deadline
    click_on :commit_request
  end

  def define_tarifs
    visit manage_booking_path(booking)
    find('.checklist li:nth-child(1) a').click
    tarifs.each do |tarif|
      expect(page).to have_content(tarif.label)
    end
    find_all('input[type="checkbox"]:not(:checked)').each(&:check)
    click_on :commit
  end

  def create_contract
    visit manage_booking_path(booking)
    find('.checklist li:nth-child(2) a').click
    visit new_manage_booking_contract_path(booking)
    click_on :commit
    find('table tbody tr:nth-child(1) td:nth-child(1) a').click
  end

  def create_deposit
    visit manage_booking_path(booking)
    find('.checklist li:nth-child(3) a').click
    click_on Invoices::Deposit.model_name.human
    click_on :commit
  end

  def confirm_booking
    visit manage_booking_path(booking)
    click_on :email_contract_and_deposit
    click_on :mark_contract_signed
  end

  def perform_booking
    visit manage_booking_path(booking)
    click_on :allowed_transitions
    click_on :active
    click_on :allowed_transitions
    click_on :past
  end

  def set_usages
    visit manage_booking_path(booking)
    find('.checklist li:nth-child(1) a').click
    # page.driver.browser.navigate.refresh
    find_all('input[type="number"]').each do |usage_field|
      usage_field.fill_in with: 22
    end
    click_on :commit
  end

  def create_invoice
    visit manage_booking_path(booking)
    find('.checklist li:nth-child(2) a').click
    click_on Invoices::Invoice.model_name.human
    # page.driver.browser.navigate.refresh
    click_on :commit
  end

  def finalize_booking
    visit manage_booking_path(booking)
    click_on :email_invoice
    click_on :postpone_deadline
    click_on :mark_invoices_paid
  end

  def check_booking
    booking.reload
    expect(booking.messages.count).to be 8
    expect(booking.booking_transitions.count).to be 10
  end
end
