# frozen_string_literal: true

module BookingActions
  module Manage
    def self.all
      @all ||= [
        Accept, EmailContractAndDeposit, EmailContractWithoutDeposit,
        EmailInvoices, EmailOffers, BookingActions::Public::PostponeDeadline,
        MarkContractSigned, BookingActions::Manage::CommitRequest,
        BookingActions::Public::CommitBookingAgentRequest, Cancel
      ].index_by(&:action_name)
    end
  end
end
