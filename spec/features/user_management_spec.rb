# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

feature 'User Management', :devise do
  after(:each) { Warden.test_reset! }

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let!(:users) { create_list(:user, 4) }

  context 'as admin' do
    before(:each) { login_as(admin, scope: :user) }

    scenario 'see all email addresses on the index' do
      visit users_path
      expect(page).to have_content admin.email
      users.each do |u|
        expect(page).to have_content(u.email)
      end
    end

    scenario 'show a user' do
      user
      visit users_path
      within find_resource_in_table(user) do
        click_link user.email
      end
      expect(page).to have_current_path(user_path(user))
      expect(page).to have_http_status(200)
      expect(page).to have_content user.email
    end

    scenario 'edit a user' do
      changed_user = build(:user)
      visit edit_user_path(user)
      fill_in :user_email, with: changed_user.email
      submit_form
      expect(page).to have_http_status 200
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: User.model_name.human)
      expect(page).to have_content changed_user.email
    end

    scenario 'can delete existing user' do
      user
      visit users_path
      within find_resource_in_table(user) do
        click_link I18n.t('destroy')
      end
      expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: User.model_name.human)
      expect(page).not_to have_content user.email
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
