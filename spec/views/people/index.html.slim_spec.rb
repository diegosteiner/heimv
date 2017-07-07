require 'rails_helper'

describe 'people/index', type: :view do
  let(:people) { create_list(:person, 2) }
  before(:each) { assign(:people, people) }

  it 'renders a list of people' do
    render
    assert_select 'tr', count: 2
  end
end
