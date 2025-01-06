class AddBookingStateSettingsToOrganisations < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :booking_state_settings, :jsonb, default: {}
    add_column :organisations, :booking_settings, :jsonb, default: {}
    add_column :organisations, :deadline_settings, :jsonb, default: {}

    reversible do |direction|
      direction.up do
        Organisation.find_each do |organisation|
          settings_hash = JSON.parse(organisation.attributes_before_type_cast["settings"])
          organisation.booking_state_settings = BookingStateSettings
            .from_value(settings_hash.slice(:occupied_occupancy_states, :default_manage_transition_to_state))

          organisation.deadline_settings = DeadlineSettings
            .from_value(settings_hash.slice(:unconfirmed_request_deadline, :provisional_request_deadline,
                                            :awaiting_tenant_deadline, :overdue_request_deadline,
                                            :awaiting_contract_deadline, :deadline_postponable_for,
                                            :deposit_payment_deadline, :invoice_payment_deadline,
                                            :payment_overdue_deadline))
        end
      end
    end
  end
end
