module BookingStrategies
  class Default
    module Actions
      class Manage < BookingStrategy::Actions
        register Accept
        register EmailContractAndDeposit
        register EmailInvoice
        register ::BookingStrategies::Default::Actions::Public::ExtendDeadline
        register MarkContractSigned
        register MarkDepositsPaid
        register MarkInvoicesPaid
        register Public::CommitRequest

        register Public::Cancel
      end
    end
  end
end
