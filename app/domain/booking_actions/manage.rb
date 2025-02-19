# frozen_string_literal: true

module BookingActions
  module Manage
    def self.all
      @all ||= [
        Accept, EmailContract, MarkContractSent, MarkInvoicesRefunded,
        EmailInvoices, EmailOffers, BookingActions::Public::PostponeDeadline,
        MarkContractSigned, BookingActions::Manage::CommitRequest, Cancel, RevertCancel
      ].index_by(&:to_sym)
    end
  end
end
