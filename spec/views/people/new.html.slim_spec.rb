require 'rails_helper'

RSpec.describe 'people/new', type: :view do
  before(:each) do
    assign(:person, Person.new(
                      firstname: 'MyString',
                      lastname: 'MyString',
                      street_address: 'MyString',
                      zipcode: 'MyString',
                      city: 'MyString'
    ))
  end

  it 'renders new person form' do
    render

    assert_select 'form[action=?][method=?]', people_path, 'post' do
      assert_select 'input[name=?]', 'person[firstname]'

      assert_select 'input[name=?]', 'person[lastname]'

      assert_select 'input[name=?]', 'person[street_address]'

      assert_select 'input[name=?]', 'person[zipcode]'

      assert_select 'input[name=?]', 'person[city]'
    end
  end
end
