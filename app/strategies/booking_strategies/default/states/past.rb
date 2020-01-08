module BookingStrategies
  class Default
    module States
      class Past < BookingStrategy::State
        def checklist
          [
            ChecklistItem.new(:create_usages, booking.usages_entered?, [:manage, booking, Usage]),
            ChecklistItem.new(:create_invoice, booking.invoices.invoice.exists?, [:manage, booking, Invoice])
          ]
        end

        def self.to_sym
          :past
        end

        def relevant_time
          booking.occupancy.ends_at
        end
      end
    end
  end
end
