# frozen_string_literal: true

module Manage
  class OrganisationParams < ApplicationParams
    def self.permitted_keys
      %i[name address esr_beneficiary_account esr_ref_prefix logo location bcc
         ref_template iban qr_iban mail_from locale default_payment_info_type creditor_address
         representative_address contract_signature email notifications_enabled]
    end

    def self.admin_permitted_keys
      permitted_keys + %i[smtp_settings slug]
    end
  end
end
