module BookingStrategies
  class Default
    module States
      class PaymentOverdue < BookingStrategy::State
        def checklist
          [
            ChecklistItem.new(:invoice_paid, booking.invoices.all?(&:paid), [:manage, booking, Invoice])
          ]
        end

        def self.to_sym
          :payment_overdue
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
