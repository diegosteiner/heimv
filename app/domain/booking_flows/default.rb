# frozen_string_literal: true

module BookingFlows
  class Default < Base
    state BookingStates::Initial, to: %i[unconfirmed_request provisional_request
                                         definitive_request open_request upcoming], initial: true
    state BookingStates::UnconfirmedRequest, to: %i[cancelled_request declined_request open_request]
    state BookingStates::OpenRequest, to: %i[cancelled_request declined_request provisional_request
                                             definitive_request booking_agent_request]
    state BookingStates::BookingAgentRequest, to: %i[cancelled_request declined_request
                                                     awaiting_tenant overdue_request]
    state BookingStates::ProvisionalRequest, to: %i[definitive_request overdue_request
                                                    cancelled_request declined_request]
    state BookingStates::OverdueRequest, to: %i[cancelled_request declined_request
                                                definitive_request awaiting_tenant]
    state BookingStates::DefinitiveRequest, to: %i[cancelation_pending awaiting_contract]

    state BookingStates::AwaitingTenant, to: %i[definitive_request overdue_request cancelled_request
                                                declined_request overdue_request]
    state BookingStates::AwaitingContract, to: %i[cancelation_pending upcoming overdue]
    state BookingStates::Overdue, to: %i[cancelation_pending upcoming]

    state BookingStates::Upcoming, to: %i[cancelation_pending upcoming_soon]
    state BookingStates::UpcomingSoon, to: %i[cancelation_pending active]
    state BookingStates::Active, to: :past
    state BookingStates::Past, to: %i[completed payment_due]

    state BookingStates::PaymentDue, to: %i[payment_overdue completed]
    state BookingStates::PaymentOverdue, to: %i[completed]

    state BookingStates::Completed
    state BookingStates::CancelledRequest
    state BookingStates::DeclinedRequest
    state BookingStates::CancelationPending, to: %i[cancelled]
    state BookingStates::Cancelled
  end
end
