class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings = Booking.open)
    bookings.find_each do |booking|
      booking.state_transition
    end
  end
end
