# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

describe 'Tenant CRUD', :devise, skip: true do
  before { signin(user, user.password) }

  after { Warden.test_reset! }

  let(:organisation_user) { create(:organisation_user) }
  let(:user) { organisation_user.user }
  let(:tenant) { create(:tenant) }
  let(:new_tenant) { build(:tenant) }

  it 'can create new tenant' do
    visit new_manage_tenant_path
    fill_in :tenant_first_name, with: new_tenant.first_name
    fill_in :tenant_last_name, with: new_tenant.last_name
    fill_in :tenant_email, with: new_tenant.email
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content I18n.t('flash.actions.create.notice', resource_name: Tenant.model_name.human)
    expect(page).to have_content new_tenant.first_name
    expect(page).to have_content new_tenant.last_name
    expect(page).to have_content new_tenant.email
  end

  it 'can see a tenant' do
    tenant
    visit manage_tenants_path
    within find_resource_in_table(tenant) do
      click_link tenant.name
    end
    expect(page).to have_current_path(manage_tenant_path(tenant))
    expect(page).to have_http_status(200)
    expect(page).to have_content tenant.name
  end

  it 'can edit existing tenant' do
    visit edit_manage_tenant_path(tenant)
    fill_in :tenant_first_name, with: new_tenant.first_name
    fill_in :tenant_last_name, with: new_tenant.last_name
    fill_in :tenant_email, with: new_tenant.email
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Tenant.model_name.human)
    expect(page).to have_content new_tenant.first_name
    expect(page).to have_content new_tenant.last_name
    expect(page).to have_content new_tenant.email
  end

  it 'can delete existing tenant' do
    tenant
    visit manage_tenants_path
    within find_resource_in_table(tenant) do
      click_link I18n.t('destroy')
    end
    expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: Tenant.model_name.human)
    expect(page).not_to have_content tenant.name
  end
end
