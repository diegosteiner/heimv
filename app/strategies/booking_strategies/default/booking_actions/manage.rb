module BookingStrategies
  class Default
    module BookingActions
      class Manage < BookingStrategy::BookingActions
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
