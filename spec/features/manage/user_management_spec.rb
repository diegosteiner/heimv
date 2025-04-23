# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

describe 'User Management', :devise, :skip do
  after { Warden.test_reset! }

  let(:organisation) { create(:organisation) }
  let(:organisation_manager_user) { create(:organisation_user) }
  let(:manager) { organisation_manager_user.user }
  let(:organisation_user) { create(:organisation_user) }
  let(:user) { organisation_user.user }
  let!(:users) { create_list(:organisation_user, 4, organisation:) }

  context 'with a manager' do
    before { login_as(manager, scope: :user) }

    it 'see all email addresses on the index' do
      visit manage_organisation_users_path
      expect(page).to have_content manager.email
      users.each do |u|
        expect(page).to have_content(u.email)
      end
    end

    it 'show a user' do
      user
      visit manage_organisation_users_path
      within find_resource_in_table(user) do
        click_link user.email
      end
      expect(page).to have_current_path(manage_user_path(user))
      expect(page).to have_http_status(:ok)
      expect(page).to have_content user.email
    end

    it 'edit a user' do
      changed_user = build(:user)
      visit edit_manage_user_path(user)
      fill_in :user_email, with: changed_user.email
      submit_form
      expect(page).to have_http_status :ok
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: User.model_name.human)
      expect(page).to have_content changed_user.email
    end

    it 'can delete existing user' do
      user
      visit manage_organisation_users_path
      within find_resource_in_table(user) do
        click_link I18n.t('destroy')
      end
      expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: User.model_name.human)
      expect(page).to have_no_content user.email
    end
  end

  context 'with an unprivileged user' do
    it 'get denied' do
      login_as(user, scope: :user)
      visit manage_organisation_users_path
      expect(page).to have_http_status(:forbidden)
      visit manage_user_path(user)
      expect(page).to have_http_status(:forbidden)
      visit edit_manage_user_path(user)
      expect(page).to have_http_status(:forbidden)
    end
  end
end
