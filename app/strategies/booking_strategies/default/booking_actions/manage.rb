module BookingStrategies
  class Default
    module Actions
      class Manage < BookingStrategy::Actions
        register Accept
        register EmailContractAndDeposit
        register EmailInvoice
        register ExtendDeadline
        register MarkContractSigned
        register MarkDepositsPaid
        register MarkInvoicesPaid

        register Cancel
      end
    end
  end
end
