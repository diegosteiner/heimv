class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings = Booking.inconcluded)
    bookings.find_each do |booking|
      Rails.logger.info booking.state_transition
    end
  end
end
