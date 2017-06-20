require 'rails_helper'

RSpec.describe 'people/index', type: :view do
  before(:each) do
    assign(:people, [
             Person.create!(
               firstname: 'Firstname',
               lastname: 'Lastname',
               street_address: 'Street Address',
               zipcode: 'Zipcode',
               city: 'City'
             ),
             Person.create!(
               firstname: 'Firstname',
               lastname: 'Lastname',
               street_address: 'Street Address',
               zipcode: 'Zipcode',
               city: 'City'
             )
           ])
  end

  it 'renders a list of people' do
    render
    assert_select 'tr>td', text: 'Firstname'.to_s, count: 2
    assert_select 'tr>td', text: 'Lastname'.to_s, count: 2
    assert_select 'tr>td', text: 'Street Address'.to_s, count: 2
    assert_select 'tr>td', text: 'Zipcode'.to_s, count: 2
    assert_select 'tr>td', text: 'City'.to_s, count: 2
  end
end
