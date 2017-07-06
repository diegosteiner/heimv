require 'rails_helper'

RSpec.describe 'homes/new', type: :view do
  before(:each) do
    @home = assign(:home, create(:home))
  end

  it 'renders new home form' do
    render

    assert_select 'form[action=?][method=?]', homes_path, 'post' do
      assert_select 'input[name=?]', 'home[name]'

      assert_select 'input[name=?]', 'home[ref]'
    end
  end
end
