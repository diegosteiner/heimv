module BookingStrategies
  class Default < BookingStrategy
    REQUIRED_MARKDOWN_TEMPLATES = %i[
      contract_text
      deposit_invoice_text
      invoice_invoice_text
      late_notice_invoice_text
      upcoming_message
      definitive_request_message
      overdue_request_message
      provisional_request_message
      confirmed_message
      open_request_message
      unconfirmed_request_message
      manage_new_booking_mail
      payment_overdue_message
      contract_signed_message
      deposit_paid_message
      invoice_paid_message
    ].freeze

    def public_actions
      actions = [
        Actions::Public::CommitRequest,
        Actions::Public::CommitBookingAgentRequest,
        Actions::Public::ExtendDeadline,
        Actions::Public::Cancel
      ]
      @public_actions ||= Hash[actions.map { |action| [action.action_name, action] }]
    end

    def manage_actions
      actions = [
        Actions::Manage::Accept, Actions::Manage::EmailContractAndDeposit,
        Actions::Manage::EmailInvoice, Actions::Public::ExtendDeadline,
        Actions::Manage::MarkContractSigned, Actions::Manage::MarkDepositsPaid,
        Actions::Manage::MarkInvoicesPaid, Actions::Public::CommitRequest,
        Actions::Manage::Cancel
      ]
      @manage_actions ||= Hash[actions.map { |action| [action.action_name, action] }]
    end
  end
end
