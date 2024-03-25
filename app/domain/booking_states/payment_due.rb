# frozen_string_literal: true

module BookingStates
  class PaymentDue < Base
    include Rails.application.routes.url_helpers

    def checklist
      booking.invoices.kept.sent.unsettled.ordered.map { settle_invoice_checklist_item(_1) }
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
      payable_until = unpaid_invoices.map(&:payable_until).max
      next if payable_until.blank?

      booking.deadlines.create(at: payable_until + booking.organisation.settings.payment_overdue_deadline,
                               postponable_for: booking.organisation.settings.deadline_postponable_for)
    end

    infer_transition(to: :completed) do |booking|
      !booking.invoices.kept.sent.unsettled.exists?
    end

    infer_transition(to: :payment_overdue) do |booking|
      booking.deadline_exceeded?
    end

    def relevant_time
      booking.deadline&.at
    end

    protected

    def settle_invoice_checklist_item(invoice)
      ChecklistItem.new(invoice.credit? ? :credit_issued : :invoice_paid,
                        invoice.settled?,
                        new_manage_booking_payment_path(booking,
                                                        payment: { invoice_id: invoice.id },
                                                        org: booking.organisation,
                                                        locale: I18n.locale))
    end
  end
end
