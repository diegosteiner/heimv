# frozen_string_literal: true

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

        def self.successors
          %i[payment_overdue completed]
        end

        after_transition do |booking|
          invoice = booking.invoices.sent.unpaid.order(payable_until: :asc).last
          payable_until = invoice&.payable_until || 30.days.from_now
          postponable_for = booking.organisation.short_deadline
          booking.deadline&.clear
          booking.deadlines.create(at: payable_until, postponable_for: postponable_for) unless booking.deadline
        end

        # infer_transition(from: %i[payment_due], to: :payment_overdue) do |booking|
        #   booking.invoices.unpaid.overdue.exists?
        # end

        infer_transition(to: :payment_overdue, &:deadline_exceeded?)
        infer_transition(to: :completed) do |booking|
          !booking.invoices.unpaid.relevant.exists?
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
