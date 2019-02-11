module BookingStrategies
  class Default
    module BookingActions
      class Manage < BookingStrategy::BookingActions
        register Accept
        register EmailContractAndDeposit
        register EmailInvoice
        register Cancel
      end
    end
  end
end
