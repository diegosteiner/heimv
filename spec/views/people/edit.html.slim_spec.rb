require 'rails_helper'

RSpec.describe 'people/edit', type: :view do
  before(:each) do
    @person = assign(:person, Person.create!(
                                first_name: 'MyString',
                                last_name: 'MyString',
                                street_address: 'MyString',
                                zipcode: 'MyString',
                                city: 'MyString'
    ))
  end

  it 'renders the edit person form' do
    render

    assert_select 'form[action=?][method=?]', person_path(@person), 'post' do
      assert_select 'input[name=?]', 'person[first_name]'

      assert_select 'input[name=?]', 'person[last_name]'

      assert_select 'input[name=?]', 'person[street_address]'

      assert_select 'input[name=?]', 'person[zipcode]'

      assert_select 'input[name=?]', 'person[city]'
    end
  end
end
