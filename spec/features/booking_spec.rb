# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

describe 'Booking', :devise, js: true, skip: true do
  let(:organisation) { create(:organisation) }
  let(:user) { create(:user, organisation: organisation) }
  let(:home) { create(:home, organisation: organisation) }
  let(:booking) { create(:booking, organisation: organisation, home: home) }

  before { login_as(user, scope: :user) }

  after { Warden.test_reset! }

  it 'can accept booking' do
    booking
    visit manage_booking_path
    click booking.ref
    expect(page).to have_http_status(200)
    # expect(page).to have_content I18n.t('flash.actions.create.notice', resource_name: Booking.model_name.human)
  end
end
