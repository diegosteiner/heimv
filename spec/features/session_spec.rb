# frozen_string_literal: true

feature 'Session', :devise, skip: true do
  let(:user) { create(:user) }

  feature 'Sign in' do
    scenario 'user cannot sign in if not registered' do
      signin('test@example.com', 'please123')
      expect(page).to have_content I18n.t 'devise.failure.not_found_in_database',
                                          authentication_keys: User.human_attribute_name(:email)
    end

    scenario 'user can sign in with valid credentials' do
      signin(user.email, user.password)
      expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    end

    scenario 'user cannot sign in with wrong email' do
      signin('invalid@email.com', user.password)
      expect(page).to have_content I18n.t 'devise.failure.not_found_in_database',
                                          authentication_keys: User.human_attribute_name(:email)
    end

    scenario 'user cannot sign in with wrong password' do
      signin(user.email, 'invalidpass')
      expect(page).to have_content I18n.t 'devise.failure.invalid',
                                          authentication_keys: User.human_attribute_name(:email)
    end
  end

  feature 'Sign out' do
    scenario 'user signs out successfully' do
      signin(user.email, user.password)
      expect(page).to have_content I18n.t 'devise.sessions.signed_in'
      click_link I18n.t 'nav.sign_out'
      expect(page).to have_content I18n.t 'devise.sessions.signed_out'
    end
  end
end
