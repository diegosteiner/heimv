class RenameConfirmedToAwaitingContract < ActiveRecord::Migration[6.0]
  def up
    BookingTransition.where(to_state: 'confirmed').update_all(to_state: 'awaiting_contract')
    Booking.where(state: 'confirmed').update_all(state: 'awaiting_contract')
  end

  def down
    BookingTransition.where(to_state: 'awaiting_contract').update_all(to_state: 'confirmed')
    Booking.where(state: 'awaiting_contract').update_all(state: 'confirmed')
  end
end
