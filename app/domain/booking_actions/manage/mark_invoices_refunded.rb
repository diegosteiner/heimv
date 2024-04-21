# frozen_string_literal: true

module BookingActions
  module Manage
    class MarkInvoicesRefunded < BookingActions::Base
      def invoke!(invoices = refundable_invoices)
        invoices.map do |invoice|
          invoice.payments.create!(amount: invoice.amount_open, confirm: false, paid_at: Time.zone.now)
        end

        Result.success
      end

      def allowed?
        refundable_invoices.any?
      end

      def refundable_invoices
        booking.invoices.kept.refund.unsettled
      end
    end
  end
end
