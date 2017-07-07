require 'rails_helper'

RSpec.describe 'bookings/index', type: :view do
  before(:each) do
    @booking = assign(:bookings, create_list(:booking, 2))
  end

  it 'renders a list of bookings' do
    render
    assert_select 'tr', count: 3
  end
end
