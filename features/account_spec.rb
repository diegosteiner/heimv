# frozen_string_literal: true

include Warden::Test::Helpers
Warden.test_mode!

feature 'User Account', :devise do
  after(:each) do
    Warden.test_reset!
  end

  let(:user) { create(:user) }

  feature 'Edit Account' do
    scenario 'user changes email address' do
      login_as(user, scope: :user)
      visit edit_user_registration_path(user)
      fill_in :user_email, with: 'newemail@example.com'
      fill_in :user_current_password, with: user.password
      submit_form
      txts = [I18n.t('devise.registrations.updated'), I18n.t('devise.registrations.update_needs_confirmation')]
      expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
    end

    scenario "user cannot cannot edit another user's profile", :me do
      me = user
      other = create(:user, email: 'other@example.com')
      login_as(me, scope: :user)
      visit edit_user_registration_path(other)
      expect(page).to have_field(:user_email, with: me.email)
    end
  end

  feature 'Suspend Account', :js do
    scenario 'user can delete own account' do
      skip 'skip a slow test'
      login_as(user, scope: :user)
      visit edit_user_registration_path(user)
      click_button 'Cancel my account'
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content I18n.t 'devise.registrations.destroyed'
    end
  end
end
