# frozen_string_literal: true

describe 'User Account', :devise, :skip do
  let(:user) { create(:user) }

  describe 'Edit Account' do
    it 'user changes email address' do
      signin(user, user.password)
      visit edit_user_registration_path(user)
      fill_in :user_email, with: 'newemail@example.com'
      fill_in :user_current_password, with: user.password
      submit_form
      txts = [I18n.t('devise.registrations.updated'), I18n.t('devise.registrations.update_needs_confirmation')]
      expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
    end

    it "user cannot cannot edit another user's profile", :me do
      me = user
      other = create(:organisation_user, :manager, email: 'other@example.com')
      login_as(me, scope: :user)
      visit edit_user_registration_path(other.user)
      expect(page).to have_field(:user_email, with: me.email)
    end
  end
end
