# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

feature 'User Management page', :devise do
  after(:each) do
    Warden.test_reset!
  end

  context 'as admin' do
    let(:user) { create(:user, :admin) }

    scenario 'user sees own email address' do
      login_as(user, scope: :user)
      visit users_path
      expect(page).to have_content user.email
    end
  end

  context 'as unprivileged user' do
    let(:user) { create(:user) }

    scenario 'user get denied' do
      login_as(user, scope: :user)
      visit users_path
      expect(page).to have_http_status(403)
    end
  end
end
