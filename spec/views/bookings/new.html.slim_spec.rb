require 'rails_helper'

RSpec.describe 'bookings/new', type: :view do
  before(:each) { assign(:booking, Booking.new) }

  it 'renders new booking form' do
    render

    assert_select 'form[action=?][method=?]', bookings_path, 'post'
  end
end
