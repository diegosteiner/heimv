require 'rails_helper'

RSpec.describe "contracts/index", type: :view do
  before(:each) do
    assign(:contracts, [
      Contract.create!(
        :booking => nil,
        :title => "Title",
        :text => "MyText"
      ),
      Contract.create!(
        :booking => nil,
        :title => "Title",
        :text => "MyText"
      )
    ])
  end

  it "renders a list of contracts" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
