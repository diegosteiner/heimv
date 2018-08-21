module BookingStrategy
  module Default
    class StateMachineAutomator < ::StateMachineAutomator
      automatic_transition(from: :initial, to: :new_request) do |booking|
        booking.email.present?
      end

      automatic_transition(from: :new_request, to: :confirmed_new_request) do |booking|
        booking.customer.valid? && booking.initiator == :tenant
      end

      automatic_transition(from: :confirm_new_request, to: :provisional_request) do |booking|
        booking.customer.reservations_allowed
      end

      automatic_transition(to: :cancelled) do |booking|
        booking.cancellation_reason.present?
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
