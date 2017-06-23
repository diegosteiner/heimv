require 'rails_helper'

RSpec.describe 'homes/index', type: :view do
  before(:each) do
    assign(:homes, [
             Home.create!(
               name: 'Name',
               ref: 'Ref'
             ),
             Home.create!(
               name: 'Name',
               ref: 'Ref'
             )
           ])
  end

  it 'renders a list of homes' do
    render
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
    assert_select 'tr>td', text: 'Ref'.to_s, count: 2
  end
end
