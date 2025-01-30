# frozen_string_literal: true

module Manage
  class OrganisationParams < ApplicationParams
    def self.permitted_keys
      %i[name address logo location bcc cors_origins iban esr_ref_prefix
         mail_from locale default_payment_info_type creditor_address account_address
         representative_address contract_signature email notifications_enabled] +
        I18n.available_locales.map { |locale| ["nickname_label_#{locale}"] }.flatten +
        [{ settings: settings_permitted_keys, deadline_settings: deadline_settings_permitted_keys,
           booking_state_settings: booking_state_settings_permitted_keys }]
    end

    def self.settings_permitted_keys
      %i[tenant_birth_date_required booking_window last_minute_warning upcoming_soon_window
         occupied_occupancy_color tentative_occupancy_color closed_occupancy_color
         default_calendar_view predefined_salutation_form contract_sign_by_click_enabled
         default_begins_at_time default_ends_at_time] +
        [{ locales: [] }]
    end

    def self.booking_state_settings_permitted_keys
      %i[default_manage_transition_to_state] +
        [{ occupied_occupancy_states: [], editable_occupancy_states: [] }]
    end

    def self.deadline_settings_permitted_keys
      %i[awaiting_contract_deadline awaiting_tenant_deadline invoice_payment_deadline
         overdue_request_deadline unconfirmed_request_deadline provisional_request_deadline
         deposit_payment_deadline deadline_postponable_for payment_overdue_deadline]
    end

    def self.admin_permitted_keys
      permitted_keys + %i[smtp_settings slug booking_flow_type currency
                          booking_ref_template tenant_ref_template invoice_ref_template invoice_payment_ref_template]
    end
  end
end
