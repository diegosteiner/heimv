# frozen_string_literal: true

module BookingActions
  class CommitRequest < Base
    def invoke!(current_user: nil)
      Result.new success: booking.update(committed_request: true)
    end

    def invokable?(current_user: nil)
      return false if booking.committed_request || booking.agent_booking || booking.email.blank? ||
                      !booking.in_state?(:provisional_request, :booking_agent_request, :overdue_request)

      booking.valid?(:public_update)
    end

    def invokable_with(current_user: nil)
      { confirm: I18n.t(:confirm) } if invokable?(current_user:)
    end
  end
end
