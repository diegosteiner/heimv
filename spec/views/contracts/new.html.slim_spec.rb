require 'rails_helper'

RSpec.describe 'contracts/new', type: :view do
  before(:each) do
    assign(:contract, Contract.new(
                        booking: nil,
                        title: 'MyString',
                        text: 'MyText'
    ))
  end

  it 'renders new contract form' do
    render

    assert_select 'form[action=?][method=?]', contracts_path, 'post' do
      assert_select 'input[name=?]', 'contract[booking_id]'

      assert_select 'input[name=?]', 'contract[title]'

      assert_select 'textarea[name=?]', 'contract[text]'
    end
  end
end
