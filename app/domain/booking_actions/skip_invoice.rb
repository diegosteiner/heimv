# frozen_string_literal: true

module BookingActions
  class SkipInvoice < Base
    def invoke!(current_user: nil)
      Result.new success: booking.update(transition_to: :completed)
    end

    def invokable?(current_user: nil)
      booking.can_transition_to?(:completed) && booking.in_state?(:past) && booking.invoices.unsent.none?
    end
  end
end
