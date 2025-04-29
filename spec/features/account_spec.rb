# frozen_string_literal: true

describe 'User Account', :devise do
  let(:user) { create(:user) }
  let(:new_password) { 'test1234!' }

  describe 'Edit Account' do
    it 'user changes email address' do
      signin(user, user.password)
      visit edit_account_path(user)
      fill_in :user_password, with: new_password
      submit_form
      expect(page).to have_content I18n.t('flash.actions.update.alert', resource_name: User.model_name.human)
      fill_in :user_password, with: new_password
      fill_in :user_password_confirmation, with: new_password
      submit_form
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: User.model_name.human)
    end
  end
end
