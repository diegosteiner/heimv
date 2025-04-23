# frozen_string_literal: true

class AddBookingStateSettingsToOrganisations < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :booking_state_settings, :jsonb, default: {} # rubocop:disable Rails/BulkChangeTable
    add_column :organisations, :deadline_settings, :jsonb, default: {}
  end
end
