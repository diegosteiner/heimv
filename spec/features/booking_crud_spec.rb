# frozen_string_literal: true

describe 'Booking CRUD', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_markdown_templates) }
  let(:user) { create(:user, organisation: organisation) }
  let(:home) { create(:home, organisation: organisation) }
  let(:booking) { create(:booking, organisation: organisation, home: home, skip_automatic_transition: false) }
  let(:new_booking) { build(:booking) }

  before do
    allow(Organisation).to receive(:current).and_return(organisation)
    signin(user, user.password)
  end

  it 'can create new booking', skip: true do
    home
    tenant = create(:tenant)
    visit new_manage_booking_path
    # find("input[name='booking[occupancy_attributes][begins_at_date]']").fill_in
    #   with: I18n.l(new_booking.occupancy.begins_at_date, format: :short)
    # find("input[name='booking[occupancy_attributes][ends_at_date]']").fill_in
    #   with: I18n.l(new_booking.occupancy.ends_at_date, format: :short)
    select tenant.name, from: :booking_tenant_id
    select home.name, from: :booking_home_id
    submit_form
    expect(page).to have_content I18n.t('flash.actions.create.notice', resource_name: Booking.model_name.human)
  end

  it 'can see a booking', skip: true do
    booking
    visit manage_bookings_path
    find_resource_in_table(booking).click
    expect(page).to have_current_path(manage_booking_path(booking))
    expect(page).to have_content booking.ref
  end

  it 'can edit existing booking' do
    screenshot_and_save_page
    visit edit_manage_booking_path(booking)
    screenshot_and_save_page
    submit_form
    screenshot_and_save_page
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Booking.model_name.human)
  end
end
