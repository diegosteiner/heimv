# frozen_string_literal: true

module BookingStrategies
  class Default < BookingStrategy
    def public_actions
      actions = [
        Actions::Public::CommitRequest,
        Actions::Public::CommitBookingAgentRequest,
        Actions::Public::PostponeDeadline,
        Actions::Public::Cancel
      ]
      @public_actions ||= actions.index_by(&:action_name)
    end

    def manage_actions
      actions = [
        Actions::Manage::Accept, Actions::Manage::EmailContractAndDeposit,
        Actions::Manage::EmailInvoice, Actions::Public::PostponeDeadline,
        Actions::Manage::MarkContractSigned, Actions::Public::CommitRequest,
        Actions::Public::CommitBookingAgentRequest, Actions::Manage::Cancel
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
  end
end
