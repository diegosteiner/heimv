module BookingStrategies
  class Default
    module States
      class Confirmed < BookingStrategy::State
        def checklist
          [
            ChecklistItem.new(:deposit_paid, booking.invoices.deposit.all?(&:paid), [:manage, booking, Invoice]),
            ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?, [:manage, booking, Contract])
          ]
        end

        def self.to_sym
          :confirmed
        end

        def relevant_time; end
      end
    end
  end
end
