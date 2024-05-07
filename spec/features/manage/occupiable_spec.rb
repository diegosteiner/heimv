# frozen_string_literal: true

describe 'Occupiable', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:organisation_user) { create(:organisation_user, :admin, organisation:) }
  let(:user) { organisation_user.user }
  let(:occupiable) { create(:occupiable, organisation:) }
  let(:new_occupiable) { build(:occupiable, organisation:) }

  before { signin(user, user.password) }

  it 'can create new occupiable' do
    visit new_manage_occupiable_path
    fill_in :occupiable_name_de, with: new_occupiable.name
    submit_form
    expect(page).to have_content I18n.t('flash.actions.create.notice', resource_name: Occupiable.model_name.human)
    expect(page).to have_content new_occupiable.name
  end

  it 'can see a occupiable' do
    occupiable
    visit manage_occupiables_path
    expect(page).to have_content occupiable.name
  end

  it 'can edit existing occupiable' do
    visit edit_manage_occupiable_path(occupiable, org: nil)
    fill_in :occupiable_name_de, with: new_occupiable.name
    submit_form
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Occupiable.model_name.human)
    expect(page).to have_content new_occupiable.name
  end

  it 'can delete existing occupiable' do
    occupiable
    visit edit_manage_occupiable_path(occupiable, org: nil)
    click_link I18n.t('destroy')
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: Occupiable.model_name.human)
  end
end
