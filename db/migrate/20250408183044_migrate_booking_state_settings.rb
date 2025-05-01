# frozen_string_literal: true

class MigrateBookingStateSettings < ActiveRecord::Migration[8.0]
  def up
    Organisation.find_each do |organisation|
      booking_state_settings = JSON.parse(organisation.booking_state_settings_before_type_cast)
      next if booking_state_settings.blank?

      if booking_state_settings.key?('editable_occupancy_states')
        booking_state_settings['editable_booking_states'] = booking_state_settings['editable_occupancy_states']
        booking_state_settings['editable_booking_states'] << 'waitlisted_request'
      end

      if booking_state_settings.key?('occupied_occupancy_states')
        booking_state_settings['occupied_booking_states'] = booking_state_settings['occupied_occupancy_states']
      end

      organisation.booking_state_settings = booking_state_settings
      organisation.save
    end
  end
end
