module BookingStrategy
  module Default
    class StateMachineAutomator < ::StateMachineAutomator
      automatic_transition(from: :initial, to: :unconfirmed_request) do |booking|
        booking.email.present?
      end

      automatic_transition(from: :unconfirmed_request, to: :open_request) do |booking|
        # booking.tenant.valid? && booking.initiator == :tenant
        booking.tenant.valid?(:public_update)
      end

      automatic_transition(to: :cancelled) do |booking|
        # booking.tenant.valid? && booking.initiator == :tenant
        booking.cancellation_reason.present?
      end

      automatic_transition(from: :provisional_request, to: :overdue_request, &:deadline_exceeded?)
      automatic_transition(from: :overdue_request, to: :cancelled, &:deadline_exceeded?)
      automatic_transition(from: :confirmed, to: :overdue, &:deadline_exceeded?)
      automatic_transition(from: :overdue, to: :cancelled, &:deadline_exceeded?)
      automatic_transition(from: :payment_due, to: :payment_overdue, &:deadline_exceeded?)

      automatic_transition(from: :upcoming, to: :active) do |booking|
        booking.occupancy.today?
      end

      automatic_transition(from: :active, to: :past) do |booking|
        booking.occupancy.past?
      end

      automatic_transition(from: :open_request, to: :provisional_request) do |booking|
        booking.tenant.reservations_allowed
      end

      automatic_transition(from: :past, to: :payment_due) do |booking|
        booking.invoices.invoice.exists?
      end

      automatic_transition(from: %i[payment_due payment_overdue], to: :completed) do |booking|
        !booking.invoices.open.exists?
      end

      # automatic_transition(from: :open_request, to: :provisional_request) do |booking|
      #   booking.valid? && !booking.committed_request.nil? && !booking.committed_request
      # end

      automatic_transition(from: %i[provisional_request overdue_request], to: :definitive_request, &:committed_request)

      automatic_transition(from: :definitive_request, to: :confirmed) do |booking|
        # booking.contracts.sent.any? && booking.invoices.deposit.any?
      end

      automatic_transition(from: :confirmed, to: :upcoming) do |booking|
        booking.contracts.signed.any? && booking.invoices.deposit.all?(&:paid)
      end

      automatic_transition(from: :upcoming, to: :active) do |booking|
        booking.occupancy.today? || booking.occupancy.past?
      end

      automatic_transition(from: :active, to: :past) do |booking|
        booking.occupancy.past?
      end
    end
  end
end
