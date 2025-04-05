# frozen_string_literal: true

module BookingActions
  class Cancel < Base
    def invoke!(current_user: nil)
      booking.errors.clear
      booking.cancellation_reason ||= I18n.t('.cancellation_reason')
      booking.transition_to = transition_to

      Result.new success: booking.save
    end

    def transition_to
      if booking.can_transition_to?(:declined_request)
        :declined_request
      elsif booking.can_transition_to?(:cancelation_pending)
        :cancelation_pending
      end
    end

    def invokable?(current_user: nil)
      transition_to.present?
    end

    def invokable_with
      { variant: :danger, prepare: true, label: } if invokable?
    end

    def label
      t(booking.committed_request ? :label_committed : :label_request)
    end
  end
end
