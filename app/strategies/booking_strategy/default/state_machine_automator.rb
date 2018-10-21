module BookingStrategy
  module Default
    class StateMachineAutomator < ::StateMachineAutomator
      automatic_transition(from: :initial, to: :new_request) do |booking|
        booking.email.present?
      end

      automatic_transition(from: :new_request, to: :confirmed_new_request) do |booking|
        booking.customer.valid? && booking.initiator == :tenant
      end

      automatic_transition(from: :confirmed_new_request, to: :overdue_request, &:deadline_exceeded?)
      automatic_transition(from: :provisional_request, to: :overdue_request, &:deadline_exceeded?)
      automatic_transition(from: :definitive_request, to: :overdue_request, &:deadline_exceeded?)
      automatic_transition(from: :overdue_request, to: :cancelled, &:deadline_exceeded?)
      automatic_transition(from: :confirmed, to: :overdue, &:deadline_exceeded?)
      automatic_transition(from: :overdue, to: :cancelled, &:deadline_exceeded?)
      automatic_transition(from: :payment_due, to: :payment_overdue, &:deadline_exceeded?)

      automatic_transition(from: :confirm_new_request, to: :provisional_request) do |booking|
        booking.customer.reservations_allowed
      end

      automatic_transition(from: :past, to: :payment_due) do |booking|
        booking.invoices.invoice.exists?
      end

      automatic_transition(from: %i[payment_due payment_overdue], to: :completed) do |booking|
        !booking.invoices.open.exists?
      end

      # automatic_transition(from: :confirmed_new_request, to: :provisional_request) do |booking|
      #   booking.valid? && !booking.committed_request.nil? && !booking.committed_request
      # end

      automatic_transition(from: :provisional_request, to: :definitive_request, &:committed_request)

      automatic_transition(from: :definitive_request, to: :confirmed) do |booking|
        booking.contracts.sent.any?
      end

      automatic_transition(from: :confirmed, to: :upcoming) do |booking|
        booking.contracts.signed.any?
      end
    end
  end
end
