# frozen_string_literal: true

class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings = Booking.inconcluded)
    transitions = {}
    bookings.includes(Booking::DEFAULT_INCLUDES).find_each do |booking|
      transitions[booking.ref] = booking.state_transition&.join(' => ').presence
    end
    Rails.logger.info transitions.compact.inspect
    true
  end
end
