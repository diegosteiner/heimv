class RenameBookingTransitionsToBookingStateTransitions < ActiveRecord::Migration[7.0]
  def change
    rename_table :booking_transitions, :booking_state_transitions
  end
end
