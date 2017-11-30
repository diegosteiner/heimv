# frozen_string_literal: true

feature 'Sign out', :devise do
  let(:user) { create(:user) }

  scenario 'user signs out successfully' do
    signin(user.email, user.password)
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    click_link 'Sign out' # TODO: Translate
    expect(page).to have_content I18n.t 'devise.sessions.signed_out'
  end
end
