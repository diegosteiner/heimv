require 'rails_helper'

RSpec.describe 'bookings/show', type: :view do
  let(:booking) { create(:booking) }
  before(:each) { assign(:booking, booking) }

  it do
    render
    expect(rendered).to have_content(booking.home.to_s)
    expect(rendered).to have_content(booking.customer.to_s)
    expect(rendered).to have_content(booking.occupancy.to_s)
  end
end
