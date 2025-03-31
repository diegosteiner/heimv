# frozen_string_literal: true

describe 'Tenant', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:org) { organisation.to_param }
  let(:organisation_user) { create(:organisation_user, :admin, organisation:) }
  let!(:tenant) { create(:tenant, organisation:) }

  before do
    signin(organisation_user.user, organisation_user.user.password)
  end

  it 'can create new tenant' do
    new_tenant = build(:tenant, organisation:)
    visit new_manage_tenant_path(org:)
    fill_in :tenant_first_name, with: new_tenant.first_name
    fill_in :tenant_last_name, with: new_tenant.last_name
    fill_in :tenant_email, with: new_tenant.email
    submit_form
    expect(page).to have_content I18n.t('flash.actions.create.notice', resource_name: Tenant.model_name.human)
    expect(page).to have_content new_tenant.first_name
    expect(page).to have_content new_tenant.last_name
    expect(page).to have_content new_tenant.email
  end

  it 'can see a tenant' do
    visit manage_tenants_path(org:)
    click_link tenant.name
    expect(page).to have_content tenant.first_name
    expect(page).to have_content tenant.last_name
    expect(page).to have_content tenant.email
  end

  it 'can edit existing tenant' do
    new_tenant = build(:tenant, organisation:)
    visit edit_manage_tenant_path(tenant, org:)
    fill_in :tenant_first_name, with: new_tenant.first_name
    fill_in :tenant_last_name, with: new_tenant.last_name
    fill_in :tenant_email, with: new_tenant.email
    submit_form
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Tenant.model_name.human)
    expect(page).to have_content new_tenant.first_name
    expect(page).to have_content new_tenant.last_name
    expect(page).to have_content new_tenant.email
  end

  it 'can delete existing tenant' do
    visit manage_tenants_path
    within find_resource_in_table(tenant) do
      click_link I18n.t('destroy')
    end

    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: Tenant.model_name.human)
    expect(page).not_to have_content tenant.full_name
  end
end
