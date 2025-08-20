# frozen_string_literal: true

module BookingFlows
  class Default < Base
    state BookingStates::Initial, to: %i[unconfirmed_request provisional_request awaiting_tenant
                                         definitive_request open_request upcoming waitlisted_request], initial: true
    state BookingStates::UnconfirmedRequest, to: %i[cancelled_request declined_request open_request]
    state BookingStates::OpenRequest, to: %i[cancelled_request declined_request provisional_request
                                             definitive_request booking_agent_request waitlisted_request]
    state BookingStates::WaitlistedRequest, to: %i[cancelled_request declined_request provisional_request
                                                   definitive_request booking_agent_request]
    state BookingStates::BookingAgentRequest, to: %i[cancelled_request declined_request
                                                     awaiting_tenant overdue_request]
    state BookingStates::ProvisionalRequest, to: %i[definitive_request overdue_request
                                                    cancelled_request declined_request]
    state BookingStates::OverdueRequest, to: %i[cancelled_request declined_request
                                                definitive_request awaiting_tenant]
    state BookingStates::DefinitiveRequest, to: %i[provisional_request cancelation_pending
                                                   awaiting_contract upcoming]
    state BookingStates::AwaitingTenant, to: %i[definitive_request overdue_request cancelled_request
                                                declined_request]
    state BookingStates::AwaitingContract, to: %i[cancelation_pending upcoming overdue]
    state BookingStates::Overdue, to: %i[cancelation_pending upcoming]

    state BookingStates::Upcoming, to: %i[cancelation_pending upcoming_soon]
    state BookingStates::UpcomingSoon, to: %i[cancelation_pending active]
    state BookingStates::Active, to: %i[cancelation_pending past]
    state BookingStates::Past, to: %i[cancelation_pending completed payment_due]

    state BookingStates::PaymentDue, to: %i[cancelation_pending payment_overdue completed]
    state BookingStates::PaymentOverdue, to: %i[cancelation_pending completed]

    state BookingStates::Completed
    state BookingStates::CancelledRequest, to: %i[open_request]
    state BookingStates::DeclinedRequest, to: %i[open_request]
    state BookingStates::CancelationPending, to: %i[cancelled]
    state BookingStates::Cancelled

    def self.displayed_by_default
      @displayed_by_default ||= %i[unconfirmed_request open_request waitlisted_request booking_agent_request
                                   provisional_request overdue_request definitive_request awaiting_tenant
                                   awaiting_contract overdue upcoming_soon active past payment_due payment_overdue
                                   cancelation_pending]
    end

    def self.occupied_by_default
      @occupied_by_default ||= %i[definitive_request awaiting_tenant awaiting_contract upcoming upcoming_soon]
    end

    def self.editable_by_default
      @editable_by_default ||= %i[initial unconfirmed_request open_request waitlisted_request provisional_request
                                  booking_agent_request awaiting_tenant overdue_request]
    end

    def self.manage_actions # rubocop:disable Metrics/MethodLength
      {
        accept: BookingActions::Accept,
        put_on_waitlist: BookingActions::PutOnWaitlist,
        email_contract: BookingActions::EmailContract,
        mark_contract_sent: BookingActions::MarkContractSent,
        mark_invoices_refunded: BookingActions::MarkInvoicesRefunded,
        email_invoice: BookingActions::EmailInvoice,
        email_quote: BookingActions::EmailQuote,
        postpone_deadline: BookingActions::PostponeDeadline,
        mark_contract_signed: BookingActions::MarkContractSigned,
        commit_request: BookingActions::CommitRequest,
        decline: BookingActions::Decline,
        revert_cancel: BookingActions::RevertCancel,
        clear_waitlist: BookingActions::ClearWaitlist
      }
    end

    def self.tenant_actions
      {
        commit_request: BookingActions::CommitRequest,
        postpone_deadline: BookingActions::PostponeDeadline,
        sign_contract: BookingActions::SignContract,
        cancel: BookingActions::Cancel
      }
    end

    def self.booking_agent_actions
      {
        commit_booking_agent_request: BookingActions::CommitBookingAgentRequest,
        postpone_deadline: BookingActions::PostponeDeadline,
        cancel: BookingActions::Cancel
      }
    end
  end
end
