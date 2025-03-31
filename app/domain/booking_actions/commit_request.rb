# frozen_string_literal: true

module BookingActions
  class CommitRequest < Base
    def invoke!
      Result.new success: booking.update(committed_request: true)
    end

    def invokable?
      booking.valid? && !booking.committed_request && (!booking.agent_booking || booking.email.present?) &&
        booking.in_state?(:provisional_request, :booking_agent_request, :overdue_request)
    end

    def invokable_with
      { confirm: I18n.t(:confirm) } if invokable?
    end
  end
end
