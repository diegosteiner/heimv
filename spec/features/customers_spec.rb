# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

feature 'Customer', :devise do
  before(:each) { login_as(user, scope: :user) }
  after(:each) { Warden.test_reset! }

  let(:user) { create(:user) }
  let(:customer) { create(:customer) }
  let(:new_customer) { build(:customer) }

  scenario 'can create new customer' do
    visit new_customer_path
    fill_in :customer_first_name, with: new_customer.first_name
    fill_in :customer_last_name, with: new_customer.last_name
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content new_customer.first_name
    expect(page).to have_content new_customer.last_name
  end

  scenario 'can see a customer' do
    customer
    visit customers_path
    within find_resource_in_table(customer) do
      click_link customer.name
    end
    expect(page).to have_current_path(customer_path(customer))
    expect(page).to have_http_status(200)
    expect(page).to have_content customer.name
  end

  scenario 'can edit existing customer' do
    visit edit_customer_path(customer)
    fill_in :customer_first_name, with: new_customer.first_name
    fill_in :customer_last_name, with: new_customer.last_name
    submit_form
    expect(page).to have_http_status(200)
    expect(page).to have_content new_customer.first_name
    expect(page).to have_content new_customer.last_name
  end

  scenario 'can delete existing customer' do
    customer
    visit customers_path
    within find_resource_in_table(customer) do
      click_link I18n.t('destroy')
    end
    expect(page).not_to have_content customer.name
  end
end
