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
      deposit_invoice_text
      invoice_invoice_text
      late_notice_invoice_text
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
        Actions::Manage::Cancel
      ]
      @manage_actions ||= Hash[actions.map { |action| [action.action_name, action] }]
    end
  end
end
