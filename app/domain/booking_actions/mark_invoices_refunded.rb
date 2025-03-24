# frozen_string_literal: true

module BookingActions
  class MarkInvoicesRefunded < Base
    def invoke!
      refundable_invoices.map do |invoice|
        invoice.payments.create!(amount: invoice.amount_open, confirm: false, paid_at: Time.zone.now)
      end

      Result.success
    end

    def invokable?
      refundable_invoices.any?
    end

    def refundable_invoices
      booking.invoices.kept.refund.unsettled
    end
  end
end
