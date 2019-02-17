class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings = Booking.inconcluded)
    bookings.find_each do |booking|
      puts booking.ref
      transitions = booking.state_transition
      Rails.logger.info transitions
      puts transitions.join(" => ")
    end
  end
end
