require 'rails_helper'

RSpec.describe 'homes/show', type: :view do
  before(:each) do
    @home = assign(:home, create(:home))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Ref/)
  end
end
