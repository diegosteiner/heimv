module BookingStrategies
  class Default
    module States
      class PaymentDue < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :payment_due
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
