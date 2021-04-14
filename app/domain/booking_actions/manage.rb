# frozen_string_literal: true

module BookingActions
  module Manage
    def self.all
      @all ||= [
        Accept, EmailContractAndDeposit,
        EmailInvoice, BookingActions::Public::PostponeDeadline,
        MarkContractSigned, BookingActions::Public::CommitRequest,
        BookingActions::Public::CommitBookingAgentRequest, Cancel
      ].index_by(&:action_name)
    end
  end
end
