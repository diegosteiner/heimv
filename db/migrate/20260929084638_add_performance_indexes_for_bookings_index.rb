# frozen_string_literal: true

class AddPerformanceIndexesForBookingsIndex < ActiveRecord::Migration[8.1]
  def change
    add_index :occupancies, :booking_id
    add_index :bookings, %i[organisation_id concluded begins_at]
    add_index :occupancies, %i[booking_id occupancy_type]
  end
end
