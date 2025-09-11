# frozen_string_literal: true

module BookingActions
  class Decline < Base
    def invoke(cancellation_reason: nil, current_user: nil)
      cancellation_reason ||= booking.cancellation_reason
      booking.update!(occupancy_type: :free, transition_to:, cancellation_reason: cancellation_reason.presence)
      Result.success
    end

    def invokable?(current_user: nil)
      transition_to.present?
    end

    def invokable_with(current_user: nil)
      { variant: :danger, prepare: true, label: } if invokable?(current_user:)
    end

    def prepare_with(cancellation_reason: nil, current_user: nil)
      return unless booking.booking_flow.current_state.to_sym == :overdue_request

      booking.cancellation_reason ||= t('deadline_exceeded')
    end

    def transition_to
      if booking.can_transition_to?(:declined_request)
        :declined_request
      elsif booking.can_transition_to?(:cancelation_pending)
        :cancelation_pending
      end
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
