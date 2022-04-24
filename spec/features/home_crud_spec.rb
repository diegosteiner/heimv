# frozen_string_literal: true

describe 'Home CRUD', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_rich_text_templates) }
  let(:organisation_user) { create(:organisation_user, :manager, organisation: organisation) }
  let(:user) { organisation_user.user }
  let(:home) { create(:home, organisation: organisation) }
  let(:new_home) { build(:home, organisation: organisation) }

  before { signin(user, user.password) }

  it 'can create new home' do
    visit new_manage_home_path
    fill_in :home_name, with: new_home.name
    submit_form
    expect(page).to have_content I18n.t('flash.actions.create.notice', resource_name: Home.model_name.human)
    expect(page).to have_content new_home.name
  end

  it 'can see a home' do
    home
    visit manage_homes_path
    click_link I18n.t('show')
    expect(page).to have_current_path(manage_home_path(home, org: nil, locale: :de))
    expect(page).to have_content home.name
  end

  it 'can edit existing home' do
    visit edit_manage_home_path(home, org: nil)
    fill_in :home_name, with: new_home.name
    submit_form
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Home.model_name.human)
    expect(page).to have_content new_home.name
  end

  it 'can delete existing home' do
    home
    visit manage_homes_path(org: nil)
    click_link I18n.t('show')
    click_link I18n.t('destroy')
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: Home.model_name.human)
    expect(page).not_to have_content home.name
  end
end
