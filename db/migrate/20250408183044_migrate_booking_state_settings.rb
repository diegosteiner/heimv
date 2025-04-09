class MigrateBookingStateSettings < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL.squish
      UPDATE organisations
      SET booking_state_settings =
        jsonb_set(booking_state_settings,
                 '{occupied_booking_states}',
                 booking_state_settings->'occupied_occupancy_states') - 'occupied_occupancy_states';
    SQL
    execute <<-SQL.squish
      UPDATE organisations
      SET booking_state_settings =
        jsonb_set(booking_state_settings,
                 '{editable_booking_states}',
                 booking_state_settings->'editable_occupancy_states') - 'editable_occupancy_states';
    SQL
  end
end
