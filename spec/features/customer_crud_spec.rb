# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

feature 'Customer CRUD', :devise do
  before(:each) { login_as(user, scope: :user) }
  after(:each) { Warden.test_reset! }

  let(:user) { create(:user) }
  let(:customer) { create(:customer) }
  let(:new_customer) { build(:customer) }

  scenario 'can create new customer' do
    visit new_manage_customer_path
    fill_in :customer_first_name, with: new_customer.first_name
    fill_in :customer_last_name, with: new_customer.last_name
    fill_in :customer_email, with: new_customer.email
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content I18n.t('flash.actions.create.notice', resource_name: Customer.model_name.human)
    expect(page).to have_content new_customer.first_name
    expect(page).to have_content new_customer.last_name
    expect(page).to have_content new_customer.email
  end

  scenario 'can see a customer' do
    customer
    visit manage_customers_path
    within find_resource_in_table(customer) do
      click_link customer.name
    end
    expect(page).to have_current_path(manage_customer_path(customer))
    expect(page).to have_http_status(200)
    expect(page).to have_content customer.name
  end

  scenario 'can edit existing customer' do
    visit edit_manage_customer_path(customer)
    fill_in :customer_first_name, with: new_customer.first_name
    fill_in :customer_last_name, with: new_customer.last_name
    fill_in :customer_email, with: new_customer.email
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Customer.model_name.human)
    expect(page).to have_content new_customer.first_name
    expect(page).to have_content new_customer.last_name
    expect(page).to have_content new_customer.email
  end

  scenario 'can delete existing customer' do
    customer
    visit manage_customers_path
    within find_resource_in_table(customer) do
      click_link I18n.t('destroy')
    end
    expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: Customer.model_name.human)
    expect(page).not_to have_content customer.name
  end
end
