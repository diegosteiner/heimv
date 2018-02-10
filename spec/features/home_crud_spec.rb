# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!
I18n.locale = 'de-CH'

feature 'Home CRUD', :devise do
  before(:each) { login_as(user, scope: :user) }
  after(:each) { Warden.test_reset! }

  let(:user) { create(:user) }
  let(:home) { create(:home) }
  let(:new_home) { build(:home) }

  scenario 'can create new home' do
    visit new_manage_home_path
    fill_in :home_name, with: new_home.name
    fill_in :home_ref, with: new_home.ref
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content I18n.t('flash.actions.create.notice', resource_name: Home.model_name.human)
    expect(page).to have_content new_home.name
  end

  scenario 'can see a home' do
    home
    visit manage_homes_path
    within find_resource_in_table(home) do
      click_link home.name
    end
    expect(page).to have_current_path(manage_home_path(home))
    expect(page).to have_http_status(200)
    expect(page).to have_content home.name
  end

  scenario 'can edit existing home' do
    visit edit_manage_home_path(home)
    fill_in :home_name, with: new_home.name
    fill_in :home_ref, with: new_home.ref
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Home.model_name.human)
    expect(page).to have_content new_home.name
  end

  scenario 'can delete existing home' do
    home
    visit manage_homes_path
    within find_resource_in_table(home) do
      click_link I18n.t('destroy')
    end
    expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: Home.model_name.human)
    expect(page).not_to have_content home.name
  end
end
