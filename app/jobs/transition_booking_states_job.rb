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
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn(e.message)

      # Wait for to be fixed https://github.com/kmcphillips/exception_notification/issues/10
      # ExceptionNotifier.notify_exception(e, data: booking.attributes) if defined?(ExceptionNotifier)
    end

    job_transitions.compact_blank
  end
end
