class SetCheckOnForAllBookingValidations < ActiveRecord::Migration[8.0]
  def up
    BookingValidation.find_each do |booking|
      booking.update(check_on: %i[public_create public_update agent_create agent_update])
    end
  end
end
