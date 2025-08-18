# frozen_string_literal: true

module BookingActions
  class MarkInvoicesRefunded < Base
    def invoke!(current_user: nil)
      refundable_invoices.map do |invoice|
        invoice.payments.create!(amount: invoice.balance, confirm: false, paid_at: Time.zone.now)
      end

      Result.success
    end

    def invokable?(current_user: nil)
      refundable_invoices.any?
    end

    def refundable_invoices
      booking.invoices.kept.refund
    end
  end
end
