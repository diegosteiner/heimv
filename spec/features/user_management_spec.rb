# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

describe 'User Management', :devise, skip: true do
  after { Warden.test_reset! }

  let(:manager) { create(:user, :manager) }
  let(:user) { create(:user) }
  let!(:users) { create_list(:user, 4) }

  context 'as manager' do
    before { login_as(manager, scope: :user) }

    it 'see all email addresses on the index' do
      visit manage_users_path
      expect(page).to have_content manager.email
      users.each do |u|
        expect(page).to have_content(u.email)
      end
    end

    it 'show a user' do
      user
      visit manage_users_path
      within find_resource_in_table(user) do
        click_link user.email
      end
      expect(page).to have_current_path(manage_user_path(user))
      expect(page).to have_http_status(200)
      expect(page).to have_content user.email
    end

    it 'edit a user' do
      changed_user = build(:user)
      visit edit_manage_user_path(user)
      fill_in :user_email, with: changed_user.email
      submit_form
      expect(page).to have_http_status 200
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: User.model_name.human)
      expect(page).to have_content changed_user.email
    end

    it 'can delete existing user' do
      user
      visit manage_users_path
      within find_resource_in_table(user) do
        click_link I18n.t('destroy')
      end
      expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: User.model_name.human)
      expect(page).not_to have_content user.email
    end
  end

  context 'as unprivileged user' do
    it 'get denied' do
      login_as(user, scope: :user)
      visit manage_users_path
      expect(page).to have_http_status(403)
      visit manage_user_path(user)
      expect(page).to have_http_status(403)
      visit edit_manage_user_path(user)
      expect(page).to have_http_status(403)
    end
  end
end
