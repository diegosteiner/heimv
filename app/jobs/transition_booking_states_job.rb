# frozen_string_literal: true

class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings = Booking.inconcluded)
    transitions = {}
    bookings.includes(Booking::DEFAULT_INCLUDES).find_each do |booking|
      transitions[booking.ref] = booking.apply_transitions&.join(' => ').presence
      Booking::Log.log(booking, user: current_user, data: { auto: true })
    end
    Rails.logger.info transitions.compact.inspect
    true
  end
end
