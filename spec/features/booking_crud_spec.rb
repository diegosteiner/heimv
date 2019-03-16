# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

feature 'Booking CRUD', :devise, js: true, skip: true do
  before(:each) { login_as(user, scope: :user) }
  after(:each) { Warden.test_reset! }

  let(:user) { create(:user) }
  let(:home) { create(:home) }
  let(:booking) { create(:booking) }
  let(:new_booking) { build(:booking) }

  scenario 'can create new booking' do
    home
    tenant = create(:tenant)
    visit new_manage_booking_path
    fill_in :booking_occupancy_attributes_begins_at, with: I18n.l(new_booking.occupancy.begins_at)
    fill_in :booking_occupancy_attributes_ends_at, with: I18n.l(new_booking.occupancy.ends_at)
    select tenant.name, from: :booking_tenant_id
    select home.name, from: :booking_home_id
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content I18n.t('flash.actions.create.notice', resource_name: Booking.model_name.human)
  end

  scenario 'can see a booking' do
    booking
    visit manage_bookings_path
    find_resource_in_table(booking).click
    expect(page).to have_current_path(manage_booking_path(booking))
    expect(page).to have_http_status(200)
    expect(page).to have_content booking.ref
  end

  scenario 'can edit existing booking' do
    visit edit_manage_booking_path(booking)
    # fill_in :booking_ref, with: new_booking.ref
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Booking.model_name.human)
  end

  scenario 'can delete existing booking' do
    visit manage_booking_path(booking)
    click_link I18n.t('destroy')
    expect(page).to have_current_path(manage_bookings_path)
    expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: Booking.model_name.human)
  end
end
