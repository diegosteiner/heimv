# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class CancelationPending < BookingStrategy::State
        def checklist
          []
        end

        def self.to_sym
          :cancelation_pending
        end

        def self.successors
          %i[cancelled overdue]
        end

        after_transition do |booking|
          booking.deadline&.clear
          booking.update!(timeframe_locked: true)
        end

        infer_transition(to: :cancelled) do |booking|
          !booking.invoices.kept.unpaid.exists?
        end

        def relevant_time; end
      end
    end
  end
end
