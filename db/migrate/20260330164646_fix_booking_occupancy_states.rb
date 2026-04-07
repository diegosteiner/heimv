# frozen_string_literal: true

class FixBookingOccupancyStates < ActiveRecord::Migration[8.1]
  def up
    # free_states = %i[declined_request cancelled_request cancelled]
    # bookings = Booking.joins(:state_transitions)
    #           .where(state_transitions: { most_recent: true, to_state: free_states }, concluded: true)
    # Occupancy.where(occupancy_type: :free, booking_id: nil)
    #          .update_all(occupancy_type: :reserved, ignore_conflicting: true)
  end
end
