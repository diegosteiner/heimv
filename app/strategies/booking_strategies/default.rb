module BookingStrategies
  class Default < BookingStrategy
    MARKDOWN_TEMPLATE_KEYS = %i[
      open_request_message
      confirmed_message
      provisional_request_message
      overdue_request_message
      definitive_request_message
      manage_new_booking_mail
      upcoming_message
      invoices_deposit_text
      invoices_invoice_text
      invoices_late_notice_text
      payment_due_message
      payment_overdue_message
      contract_text
      contract_signed_message
      deposits_paid_message
      booking_agent_request_message
      cancelled_message
      cancelled_request_message
      declined_request_message
      booking_agent_cancelled_message
      awaiting_tenant_message
      unconfirmed_request_message
      booking_agent_request_accepted_message deposit_paid_message invoice_paid_message
      foreign_payment_info_text
    ].freeze

    def public_actions
      actions = [
        Actions::Public::CommitRequest,
        Actions::Public::CommitBookingAgentRequest,
        Actions::Public::PostponeDeadline,
        Actions::Public::Cancel
      ]
      @public_actions ||= Hash[actions.map { |action| [action.action_name, action] }]
    end

    def manage_actions
      actions = [
        Actions::Manage::Accept, Actions::Manage::EmailContractAndDeposit,
        Actions::Manage::EmailInvoice, Actions::Public::PostponeDeadline,
        Actions::Manage::MarkContractSigned, Actions::Manage::MarkDepositsPaid,
        Actions::Manage::MarkInvoicesPaid, Actions::Public::CommitRequest,
        Actions::Public::CommitBookingAgentRequest, Actions::Manage::Cancel
      ]
      @manage_actions ||= Hash[actions.map { |action| [action.action_name, action] }]
    end

    def booking_states
      states = [
        States::CancelledRequest, States::DeclinedRequest, States::BookingAgentRequest, States::AwaitingTenant,
        States::UnconfirmedRequest, States::OpenRequest, States::ProvisionalRequest, States::DefinitiveRequest,
        States::OverdueRequest, States::Cancelled, States::Confirmed, States::Upcoming, States::Overdue,
        States::Active, States::Past, States::PaymentDue, States::PaymentOverdue, States::Completed,
        States::CancelationPending
      ]
      @booking_states ||= Hash[states.map { |state_klass| [state_klass.to_sym, state_klass] }]
    end

    def displayed_booking_states
      %i[unconfirmed_request open_request booking_agent_request awaiting_tenant overdue_request provisional_request
         definitive_request confirmed upcoming active past payment_due payment_overdue cancelation_pending
         completed cancelled cancelled_request declined_request]
    end
  end
end
