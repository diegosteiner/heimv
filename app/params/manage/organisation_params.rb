# frozen_string_literal: true

module Manage
  class OrganisationParams < ApplicationParams
    def self.permitted_keys
      %i[name address
         esr_beneficiary_account esr_ref_prefix notification_footer logo location bcc
         privacy_statement_pdf terms_pdf iban mail_from locale
         representative_address contract_signature email notifications_enabled]
    end

    def self.admin_permitted_keys
      permitted_keys + %i[booking_strategy_type invoice_ref_strategy_type smtp_settings slug]
    end
  end
end
