require 'rails_helper'

RSpec.describe 'bookings/edit', type: :view do
  before(:each) do
    @booking = assign(:booking, create(:booking))
  end

  it 'renders the edit booking form' do
    render

    assert_select 'form[action=?][method=?]', booking_path(@booking), 'post' do
      assert_select 'input[name=?]', 'booking[occupancy_id]'

      assert_select 'input[name=?]', 'booking[home_id]'

      assert_select 'input[name=?]', 'booking[state]'

      assert_select 'input[name=?]', 'booking[customer_id]'
    end
  end
end
