require 'rails_helper'

RSpec.describe 'bookings/index', type: :view do
  before(:each) do
    assign(:bookings, [
             Booking.create!(
               occupancy: nil,
               home: nil,
               state: 'State',
               customer: nil
             ),
             Booking.create!(
               occupancy: nil,
               home: nil,
               state: 'State',
               customer: nil
             )
           ])
  end

  it 'renders a list of bookings' do
    render
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: 'State'.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
  end
end
