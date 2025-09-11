# frozen_string_literal: true

module BookingActions
  class RevertCancel < Base
    REVERSIBLE_BOOKING_STATES = [BookingStates::CancelledRequest, BookingStates::DeclinedRequest,
                                 BookingStates::CancelationPending, BookingStates::Cancelled].map(&:to_sym).freeze

    def invoke!(current_user: nil) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      error = nil
      ActiveRecord::Base.transaction do
        reverted = booking.state_transitions.last(2).reverse.map do |state_transition|
          state_transition.destroy if REVERSIBLE_BOOKING_STATES.include?(state_transition.to_state&.to_sym)
        end

        booking.booking_flow.current_state(force_reload: true) # flush cache of statemachine
        booking.update!(occupancy_type: :occupied, concluded: false)
        error = 'Nothing reverted' if reverted.compact.none?
        raise ActiveRecord::Rollback if error.present?
      end
      Result.new success: error.blank?, error:
    end

    def invokable?(current_user: nil)
      REVERSIBLE_BOOKING_STATES.include?(booking.booking_flow.current_state&.to_sym)
    end

    def invokable_with(current_user: nil)
      { variant: :danger, confirm: I18n.t(:confirm) } if invokable?(current_user:)
    end
  end
end
