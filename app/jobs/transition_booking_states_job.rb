# frozen_string_literal: true

class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings = Booking.inconcluded)
    transitions = {}
    bookings.includes(Booking::DEFAULT_INCLUDES).find_each do |booking|
      booking_transitions = booking.apply_transitions&.compact_blank
      Booking::Log.log(booking, trigger: :auto) if booking_transitions.present?
      transitions[booking.id] = booking_transitions
    end

    transitions.filter! { |_booking_id, booking_transitions| booking_transitions.present? }
    Rails.logger.info transitions.inspect
    transitions
  end
end
