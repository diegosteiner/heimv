# frozen_string_literal: true

class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings = Booking.where(concluded: false))
    job_transitions = {}
    bookings.with_default_includes.find_each do |booking|
      transitions = booking.apply_transitions&.compact_blank
      next if transitions.blank?

      Booking::Log.log(booking, trigger: :auto, data: { transitions: })
      job_transitions[booking.id] = transitions
    end

    job_transitions.filter { |_booking_id, transitions| transitions.present? }
  end
end
