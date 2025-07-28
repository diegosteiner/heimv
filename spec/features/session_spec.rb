# frozen_string_literal: true

describe 'Session', :devise do
  let(:organisation_user) { create(:organisation_user, :manager) }
  let(:user) { organisation_user.user }

  describe 'Sign in' do
    it 'user can sign in with valid credentials' do
      signin(user.email, user.password)
      expect(page).to have_content I18n.t 'devise.sessions.signed_in'
      click_link user.email
      click_link I18n.t 'nav.sign_out'
    end

    it 'user cannot sign in if not registered' do
      signin('test@heimv.test', 'please123', verify: false)
      expect(page).to have_content I18n.t 'devise.failure.not_found_in_database',
                                          authentication_keys: User.human_attribute_name(:email)
    end

    it 'user cannot sign in with wrong email' do
      signin('invalid@email.com', user.password, verify: false)
      expect(page).to have_content I18n.t 'devise.failure.not_found_in_database',
                                          authentication_keys: User.human_attribute_name(:email)
    end

    it 'user cannot sign in with wrong password' do
      signin(user.email, 'invalidpass', verify: false)
      expect(page).to have_content I18n.t 'devise.failure.invalid',
                                          authentication_keys: User.human_attribute_name(:email)
    end
  end

  describe 'Sign out' do
    it 'user signs out successfully' do
      signin(user.email, user.password)
      expect(page).to have_content I18n.t 'devise.sessions.signed_in'
      click_link user.email
      click_link I18n.t 'nav.sign_out'
      expect(page).to have_no_content user.email
    end
  end
end
