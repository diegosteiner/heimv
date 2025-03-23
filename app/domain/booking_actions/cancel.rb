# frozen_string_literal: true

module BookingActions
  class Cancel < Base
    def invoke!
      booking.errors.clear
      booking.cancellation_reason ||= I18n.t('.cancellation_reason')
      booking.transition_to = if booking.can_transition_to?(:cancelled_request)
                                :cancelled_request
                              elsif booking.can_transition_to?(:cancelation_pending)
                                :cancelation_pending
                              end
      Result.new success: booking.save
    end

    def invokable?
      booking.can_transition_to?(:cancelled_request) || booking.can_transition_to?(:cancelation_pending)
    end

    def invokable_with
      { variant: :danger, prepare: true, label: } if invokable?
    end

    def label
      t(booking.committed_request ? :label_committed : :label_request)
    end
  end
end
