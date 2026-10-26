# frozen_string_literal: true

class MigrateFreeConflictTypes < ActiveRecord::Migration[8.1]
  def change
    up_only do
      bookings = Booking.where(conflict_type: :free)
      bookings.update_all(conflict_type: :void) # rubocop:disable Rails/SkipsModelValidations
      occupancies = Occupancy.where(conflict_type: :free).where.not(booking_id: nil)
      occupancies.update_all(conflict_type: :void) # rubocop:disable Rails/SkipsModelValidations

      Occupancy.where.not(booking_id: nil).find_each do
        next unless it.valid?

        it.sync_booking
        it.save!
      end
    end
  end
end
