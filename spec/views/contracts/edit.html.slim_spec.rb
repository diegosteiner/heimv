require 'rails_helper'

RSpec.describe 'contracts/edit', type: :view do
  before(:each) do
    @contract = assign(:contract, Contract.create!(
                                    booking: nil,
                                    title: 'MyString',
                                    text: 'MyText'
    ))
  end

  it 'renders the edit contract form' do
    render

    assert_select 'form[action=?][method=?]', booking_contract_path(@booking, @contract), 'post' do
      assert_select 'input[name=?]', 'contract[booking_id]'

      assert_select 'input[name=?]', 'contract[title]'

      assert_select 'textarea[name=?]', 'contract[text]'
    end
  end
end
