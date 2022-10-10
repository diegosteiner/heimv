# frozen_string_literal: true

module Manage
  class OrganisationParams < ApplicationParams
    def self.permitted_keys
      %i[name address logo location bcc
         ref_template iban qr_iban mail_from locale default_payment_info_type creditor_address
         representative_address contract_signature email notifications_enabled] +
        [{ settings: settings_permitted_keys }]
    end

    def self.settings_permitted_keys
      %i[tenant_birth_date_required booking_margin booking_window awaiting_contract_deadline
         overdue_request_deadline unconfirmed_request_deadline provisional_request_deadline
         last_minute_warning upcoming_soon_window invoice_payment_deadline
         deposit_payment_deadline deadline_postponable_for
         occupied_occupancy_color tentative_occupancy_color closed_occupancy_color]
    end

    def self.admin_permitted_keys
      permitted_keys + %i[smtp_settings slug]
    end
  end
end
