# frozen_string_literal: true

module BookingActions
  class Decline < Base
    def invoke(cancellation_reason: nil)
      cancellation_reason ||= booking.cancellation_reason
      transition_to = if booking.can_transition_to?(:declined_request)
                        :declined_request
                      elsif booking.can_transition_to?(:cancelation_pending)
                        :cancelation_pending
                      end

      Result.new success: booking.update(transition_to:, cancellation_reason: cancellation_reason.presence)
    end

    def invokable?
      booking.can_transition_to?(:declined_request) || booking.can_transition_to?(:cancelation_pending)
    end

    def invokable_with
      { variant: :danger, prepare: true, label: } if invokable?
    end

    def label
      t(booking.committed_request ? :label_committed : :label_request)
    end

    def invoke_schema
      Dry::Schema.Params do
        required(:cancellation_reason).filled(:string)
      end
    end
  end
end
