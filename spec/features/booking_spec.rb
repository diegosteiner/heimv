# frozen_string_literal: true

describe 'Booking', :devise do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:organisation_user) { create(:organisation_user, :manager, organisation:) }
  let(:user) { organisation_user.user }
  let(:home) { create(:home, organisation:) }
  let(:booking) { create(:booking, organisation:, home:, skip_infer_transitions: false) }
  let(:new_booking) { build(:booking) }

  before do
    signin(user, user.password)
  end

  it 'can create new booking' do
    visit new_manage_booking_path
    expect(page).to have_content Booking.model_name.human
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
