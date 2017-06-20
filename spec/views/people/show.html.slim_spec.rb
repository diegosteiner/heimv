require 'rails_helper'

RSpec.describe 'people/show', type: :view do
  before(:each) do
    @person = assign(:person, Person.create!(
                                firstname: 'Firstname',
                                lastname: 'Lastname',
                                street_address: 'Street Address',
                                zipcode: 'Zipcode',
                                city: 'City'
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Firstname/)
    expect(rendered).to match(/Lastname/)
    expect(rendered).to match(/Street Address/)
    expect(rendered).to match(/Zipcode/)
    expect(rendered).to match(/City/)
  end
end
