# frozen_string_literal: true

module BookingStates
  class PaymentDue < Base
    include Rails.application.routes.url_helpers

    def checklist
      BookingStateChecklistItem.prepare(:invoices_settled, booking:)
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :payment_due
    end

    after_transition do |booking|
      booking.deadline&.clear
      unpaid_invoices = booking.invoices.kept.sent.unpaid.ordered
      payable_until = unpaid_invoices.map(&:payable_until).compact.max
      next if payable_until.blank?

      booking.set_deadline(at: payable_until + booking.organisation.settings.payment_overdue_deadline,
                           postponable_for: booking.organisation.settings.deadline_postponable_for)
    end

    infer_transition(to: :completed) do |booking|
      !booking.invoices.kept.sent.unsettled.exists?
    end

    infer_transition(to: :payment_overdue) do |booking|
      booking.deadline_exceeded? && booking.invoices.kept.sent.unpaid.exists?
    end

    def relevant_time
      booking.deadline&.at
    end
  end
end
