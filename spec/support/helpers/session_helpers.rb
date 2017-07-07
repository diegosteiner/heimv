# frozen_string_literal: true

module Features
  module SessionHelpers
    def sign_up_with(email, password, _confirmation)
      visit new_user_registration_path
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      submit_form
    end

    def signin(email, password)
      visit new_user_session_path
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      submit_form
    end
  end
end
