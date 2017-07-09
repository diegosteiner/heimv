require 'rails_helper'

RSpec.describe "contracts/show", type: :view do
  before(:each) do
    @contract = assign(:contract, Contract.create!(
      :booking => nil,
      :title => "Title",
      :text => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
  end
end
