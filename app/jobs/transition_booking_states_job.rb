class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings = Booking.inconcluded)
    bookings.find_each(&:state_transition)
  end
end
