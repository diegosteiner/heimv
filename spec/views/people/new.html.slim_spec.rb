require 'rails_helper'

RSpec.describe 'people/new', type: :view do
  before(:each) do
    assign(:person, Person.new(
                      first_name: 'MyString',
                      last_name: 'MyString',
                      street_address: 'MyString',
                      zipcode: 'MyString',
                      city: 'MyString'
    ))
  end

  it 'renders new person form' do
    render

    assert_select 'form[action=?][method=?]', people_path, 'post' do
      assert_select 'input[name=?]', 'person[first_name]'

      assert_select 'input[name=?]', 'person[last_name]'

      assert_select 'input[name=?]', 'person[street_address]'

      assert_select 'input[name=?]', 'person[zipcode]'

      assert_select 'input[name=?]', 'person[city]'
    end
  end
end
