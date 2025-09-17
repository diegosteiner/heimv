# frozen_string_literal: true

module BookingActions
  class Cancel < Base
    def invoke!(current_user: nil)
      booking.errors.clear
      booking.update!(occupancy_type: :free, transition_to:)
      Result.success
    end

    def transition_to
      if booking.can_transition_to?(:cancelled_request)
        :cancelled_request
      elsif booking.can_transition_to?(:cancelation_pending)
        :cancelation_pending
      end
    end

    def invokable?(current_user: nil)
      transition_to.present?
    end

    def invokable_with(current_user: nil)
      { variant: :danger, prepare: true, label: } if invokable?(current_user:)
    end

    def label
      t(booking.committed_request ? :label_committed : :label_request)
    end
  end
end
