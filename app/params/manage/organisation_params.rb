# frozen_string_literal: true

module Manage
  class OrganisationParams < ApplicationParams
    def self.permitted_keys
      %i[name address
         esr_beneficiary_account esr_ref_prefix notification_footer logo location bcc ref_template
         privacy_statement_pdf terms_pdf iban mail_from locale default_payment_info_type
         representative_address contract_signature email notifications_enabled]
    end

    def self.admin_permitted_keys
      permitted_keys + %i[smtp_settings_json settings_json slug]
    end
  end
end
