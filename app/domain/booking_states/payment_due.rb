# frozen_string_literal: true

module BookingStates
  class PaymentDue < Base
    def checklist
      []
    end

    def self.to_sym
      :payment_due
    end

    after_transition do |booking|
      invoice = booking.invoices.sent.unpaid.order(payable_until: :asc).last
      payable_until = invoice&.payable_until || 30.days.from_now
      postponable_for = booking.organisation.settings.fetch(:postponable_for, 3.days)
      booking.deadline&.clear
      booking.deadlines.create(at: payable_until, postponable_for: postponable_for) unless booking.deadline
    end

    infer_transition(to: :payment_overdue, &:deadline_exceeded?)
    infer_transition(to: :completed) do |booking|
      !booking.invoices.unpaid.kept.exists? && !booking.invoices.overpaid.kept.exists?
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
