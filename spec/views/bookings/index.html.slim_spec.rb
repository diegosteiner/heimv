require 'rails_helper'

RSpec.describe 'bookings/index', type: :view do
  before(:each) do
    @booking = assign(:bookings, create_list(:booking, 2)
  end

  it 'renders a list of bookings' do
    render
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
    assert_select 'tr>td', text: 'State'.to_s, count: 2
    assert_select 'tr>td', text: nil.to_s, count: 2
  end
end
