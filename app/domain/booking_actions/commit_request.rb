# frozen_string_literal: true

module BookingActions
  class CommitRequest < Base
    def invoke!(current_user: nil)
      Result.new success: booking.update(committed_request: true)
    end

    def invokable?(current_user: nil)
      booking.valid?(:public_update) && !booking.committed_request &&
        (!booking.agent_booking || booking.email.present?) &&
        booking.in_state?(:provisional_request, :booking_agent_request, :overdue_request)
    end

    def invokable_with
      { confirm: I18n.t(:confirm) } if invokable?
    end
  end
end
