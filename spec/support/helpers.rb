# frozen_string_literal: true

module SpecHelpers
  module Feature
    def submit_form
      find_all('[name="commit"]').first.click
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

    def signin(email, password, verify: true)
      visit new_user_session_path
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      submit_form
      expect(page).to have_content(I18n.t('devise.sessions.signed_in')) if verify
    end

    def sign_out
      find_by_id('user-menu')
      click_on destroy_user_session_path
    end

    # def page_to_pdf
    #   text = Tempfile.open('pdf') do |pdf|
    #     pdf << page.source.force_encoding('UTF-8')
    #     PDF::Reader.new(pdf).pages.map(&:text)
    #   end
    #   page.driver.response.instance_variable_set(:@body, text)
    # end
  end
end

RSpec.configure do |config|
  config.include SpecHelpers::Feature, type: :feature
  # config.include Features::FormHelpers, type: :feature
end
