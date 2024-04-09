# frozen_string_literal: true

module Manage
  class OrganisationParams < ApplicationParamsSchema
    # define do
    #   %i[name address logo location bcc
    #      iban mail_from locale default_payment_info_type creditor_address
    #      representative_address contract_signature email notifications_enabled] +
    #     [{ settings: settings_permitted_keys }]
    # end

    # def self.settings_permitted_keys
    #   %i[tenant_birth_date_required booking_window awaiting_contract_deadline awaiting_tenant_deadline
    #      overdue_request_deadline unconfirmed_request_deadline provisional_request_deadline
    #      last_minute_warning upcoming_soon_window invoice_payment_deadline
    #      deposit_payment_deadline deadline_postponable_for payment_overdue_deadline
    #      occupied_occupancy_color tentative_occupancy_color closed_occupancy_color
    #      default_calendar_view default_manage_transition_to_state
    #      default_begins_at_time default_ends_at_time show_outbox] +
    #     [{ locales: [], occupied_occupancy_states: [] }]
    # end

    # def self.admin_permitted_keys
    #   permitted_keys + %i[smtp_settings slug booking_ref_template invoice_ref_template booking_flow_type currency]
    # end
  end
end
