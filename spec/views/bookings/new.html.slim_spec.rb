require 'rails_helper'

RSpec.describe 'bookings/new', type: :view do
  before(:each) do
    @booking = assign(:booking, create(:booking))
  end

  it 'renders new booking form' do
    render

    assert_select 'form[action=?][method=?]', bookings_path, 'post' do
      assert_select 'input[name=?]', 'booking[occupancy_id]'

      assert_select 'input[name=?]', 'booking[home_id]'

      assert_select 'input[name=?]', 'booking[state]'

      assert_select 'input[name=?]', 'booking[customer_id]'
    end
  end
end
