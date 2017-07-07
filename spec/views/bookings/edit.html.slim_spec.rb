require 'rails_helper'

RSpec.describe 'bookings/edit', type: :view do
  before(:each) do
    @booking = assign(:booking, create(:booking))
  end

  it 'renders the edit booking form' do
    render

    assert_select 'form[action=?][method=?]', booking_path(@booking), 'post'
  end
end
