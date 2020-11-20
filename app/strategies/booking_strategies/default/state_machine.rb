# frozen_string_literal: true

module BookingStrategies
  class Default
    class StateMachine < BookingStrategy::StateMachine
      mount States::UnconfirmedRequest, States::OpenRequest, States::ProvisionalRequest, States::DefinitiveRequest,
            States::BookingAgentRequest, States::AwaitingTenant, States::AwaitingContract, States::Overdue,
            States::Upcoming, States::UpcomingSoon, States::Active, States::Past, States::PaymentDue,
            States::CancelationPending, States::Completed, States::CancelledRequest, States::DeclinedRequest,
            States::Cancelled, States::OverdueRequest, States::PaymentOverdue, initial: States::Initial
    end
  end
end
