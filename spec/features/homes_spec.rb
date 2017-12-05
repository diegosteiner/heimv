# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

feature 'Home', :devise do
  before(:each) { login_as(user, scope: :user) }
  after(:each) { Warden.test_reset! }

  let(:user) { create(:user) }
  let(:home) { create(:home) }
  let(:new_home) { build(:home) }

  scenario 'can create new home' do
    visit new_home_path
    fill_in :home_name, with: new_home.name
    fill_in :home_ref, with: new_home.ref
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content new_home.name
  end

  scenario 'can see a home' do
    home
    visit homes_path
    within find_resource_in_table(home) do
      click_link home.name
    end
    expect(page).to have_current_path(home_path(home))
    expect(page).to have_http_status(200)
    expect(page).to have_content home.name
  end

  scenario 'can edit existing home' do
    visit edit_home_path(home)
    fill_in :home_name, with: new_home.name
    fill_in :home_ref, with: new_home.ref
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content new_home.name
  end

  scenario 'can delete existing home' do
    home
    visit homes_path
    within find_resource_in_table(home) do
      click_link I18n.t('destroy')
    end
    expect(page).not_to have_content home.name
  end
end
