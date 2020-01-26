module BookingStrategies
  class Default
    module States
      class Confirmed < BookingStrategy::State
        def checklist
          [
            ChecklistItem.new(:deposit_paid, Invoices::Deposit.of(booking).relevant.all?(&:paid),
                              [:manage, booking, Invoice]),
            ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?, [:manage, booking, Contract])
          ]
        end

        def self.to_sym
          :confirmed
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
