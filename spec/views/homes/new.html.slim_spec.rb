require 'rails_helper'

RSpec.describe 'homes/new', type: :view do
  before(:each) { assign(:home, Home.new) }

  it 'renders new home form' do
    render

    assert_select 'form[action=?][method=?]', homes_path, 'post'
  end
end
