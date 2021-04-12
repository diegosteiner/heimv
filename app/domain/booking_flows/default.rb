# frozen_string_literal: true

module BookingFlows
  class Default < BookingFlow
    def public_actions
      actions = [
        BookingActions::Public::CommitRequest,
        BookingActions::Public::CommitBookingAgentRequest,
        BookingActions::Public::PostponeDeadline,
        BookingActions::Public::Cancel
      ]
      @public_actions ||= actions.index_by(&:action_name)
    end

    def manage_actions
      actions = [
        BookingActions::Manage::Accept, BookingActions::Manage::EmailContractAndDeposit,
        BookingActions::Manage::EmailInvoice, BookingActions::Public::PostponeDeadline,
        BookingActions::Manage::MarkContractSigned, BookingActions::Public::CommitRequest,
        BookingActions::Public::CommitBookingAgentRequest, BookingActions::Manage::Cancel
      ]
      @manage_actions ||= actions.index_by(&:action_name)
    end

    def displayed_booking_states
      %i[unconfirmed_request open_request booking_agent_request awaiting_tenant overdue_request provisional_request
         definitive_request overdue awaiting_contract upcoming_soon active past payment_due payment_overdue
         cancelation_pending upcoming]
    end

    def manually_created_bookings_transition_to
      :open_request
    end

    class StateMachine < BookingStateMachine
      mount BookingStates::UnconfirmedRequest, BookingStates::OpenRequest, BookingStates::ProvisionalRequest,
            BookingStates::DefinitiveRequest, BookingStates::BookingAgentRequest, BookingStates::AwaitingTenant,
            BookingStates::AwaitingContract, BookingStates::Overdue, BookingStates::Upcoming,
            BookingStates::UpcomingSoon, BookingStates::Active, BookingStates::Past, BookingStates::PaymentDue,
            BookingStates::CancelationPending, BookingStates::Completed, BookingStates::CancelledRequest,
            BookingStates::DeclinedRequest, BookingStates::Cancelled, BookingStates::OverdueRequest,
            BookingStates::PaymentOverdue, initial: BookingStates::Initial
    end
  end
end
