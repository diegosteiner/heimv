require 'rails_helper'

RSpec.describe 'homes/index', type: :view do
  let(:homes) { create_list(:home, 2) }
  before(:each) { assign(:homes, homes) }

  it 'renders a list of homes' do
    render
    assert_select 'tr', count: 3
  end
end
