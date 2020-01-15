class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings = Booking.inconcluded)
    transitions = {}
    bookings.find_each do |booking|
      transitions[booking.ref] = booking.state_transition.join(' => ').presence
    end
    Rails.logger.info transitions.compact.inspect
  end
end
