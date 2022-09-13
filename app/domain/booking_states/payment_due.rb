# frozen_string_literal: true

module BookingStates
  class PaymentDue < Base
    include Rails.application.routes.url_helpers

    def checklist
      [
        invoice_paid_checklist_item
      ]
    end

    def invoice_type
      Invoices::Invoice
    end

    def self.to_sym
      :payment_due
    end

    after_transition do |booking|
      booking.deadline&.clear
      invoice = booking.invoices.sent.open.order(payable_until: :asc).last
      payable_until = invoice&.payable_until
      next if payable_until.blank?

      postponable_for = booking.home.settings.deadline_postponable_for
      booking.deadlines.create(at: payable_until, postponable_for: postponable_for) unless booking.deadline
    end

    infer_transition(to: :payment_overdue, &:deadline_exceeded?)
    infer_transition(to: :completed) do |booking|
      !booking.invoices.open.kept.exists? && !booking.invoices.overpaid.kept.exists?
    end

    def relevant_time
      booking.deadline&.at
    end

    def invoice_paid_checklist_item
      ChecklistItem.new(:invoices_paid, booking.invoices.kept.all?(&:paid?),
                        manage_booking_invoices_path(booking, org: booking.organisation.slug))
    end
  end
end
