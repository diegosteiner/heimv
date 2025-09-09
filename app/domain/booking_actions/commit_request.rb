# frozen_string_literal: true

module BookingActions
  class CommitRequest < Base
    def invoke!(current_user: nil)
      booking.update!(committed_request: true)

      Result.success
    end

    def invokable?(current_user: nil)
      return false if booking.committed_request || booking.agent_booking || booking.email.blank?

      booking.valid_with_attributes?(committed_request: true)
    end

    def invokable_with(current_user: nil)
      { confirm: I18n.t(:confirm) } if invokable?(current_user:)
    end
  end
end
