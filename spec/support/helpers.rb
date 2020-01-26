# frozen_string_literal: true

module SpecHelpers
  module Feature
    def submit_form
      find('input[name="commit"]').click
    end

    def find_resource_in_table(resource)
      find("tr[data-id='#{resource&.to_param || resource}']")
    end

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

    def sign_out
      find('#user-menu')
      click_on destroy_user_session_path
    end
  end
end

RSpec.configure do |config|
  config.include SpecHelpers::Feature, type: :feature
  # config.include Features::FormHelpers, type: :feature
end
