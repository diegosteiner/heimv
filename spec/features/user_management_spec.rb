# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

feature 'User Management', :devise do
  after(:each) do
    Warden.test_reset!
  end

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let!(:users) { create_list(:user, 4) }

  context 'as admin' do
    scenario 'see all email addresses on the index' do
      login_as(admin, scope: :user)
      visit users_path
      expect(page).to have_content admin.email
      users.each do |u|
        expect(page).to have_content(u.email)
      end
    end

    scenario 'edit a user' do
      changed_user = build(:user)
      login_as(admin, scope: :user)
      visit edit_user_path(user)
      fill_in :user_email, with: changed_user.email
      submit_form
      expect(page).to have_http_status 200
      expect(page).to have_content changed_user.email
    end
  end

  context 'as unprivileged user' do
    scenario 'get denied' do
      login_as(user, scope: :user)
      visit users_path
      expect(page).to have_http_status(403)
      visit user_path(user)
      expect(page).to have_http_status(403)
      visit edit_user_path(user)
      expect(page).to have_http_status(403)
    end
  end
end
