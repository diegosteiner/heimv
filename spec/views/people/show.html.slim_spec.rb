require 'rails_helper'

RSpec.describe 'people/show', type: :view do
  before(:each) do
    @person = assign(:person, Person.create!(
                                first_name: 'first_name',
                                last_name: 'last_name',
                                street_address: 'Street Address',
                                zipcode: 'Zipcode',
                                city: 'City'
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/first_name/)
    expect(rendered).to match(/last_name/)
    expect(rendered).to match(/Street Address/)
    expect(rendered).to match(/Zipcode/)
    expect(rendered).to match(/City/)
  end
end
