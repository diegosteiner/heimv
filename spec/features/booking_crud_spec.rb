# frozen_string_literal: true

describe 'Booking CRUD', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_rich_text_templates) }
  let(:user) { create(:user, :manager, organisation: organisation) }
  let(:home) { create(:home, organisation: organisation) }
  let(:booking) { create(:booking, organisation: organisation, home: home, skip_infer_transition: false) }
  let(:new_booking) { build(:booking) }

  before do
    signin(user, user.password)
  end

  it 'can create new booking' do
    visit new_manage_booking_path
  end

  it 'can see a booking' do
    booking
    visit manage_bookings_path
    click_on(booking.ref)
    expect(page).to have_current_path(manage_booking_path(booking, org: nil, locale: :de))
    expect(page).to have_content booking.ref
  end

  it 'can edit existing booking' do
    visit edit_manage_booking_path(booking, org: nil)
    # expect(page.driver.browser.manage.logs.get(:browser)).to eq([])
    submit_form
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Booking.model_name.human)
  end
end
