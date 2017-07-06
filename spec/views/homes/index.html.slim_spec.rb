require 'rails_helper'

RSpec.describe 'homes/index', type: :view do
  before(:each) do
    @home = assign(:homes, create_list(:home, 2))
  end

  it 'renders a list of homes' do
    render
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
    assert_select 'tr>td', text: 'Ref'.to_s, count: 2
  end
end
