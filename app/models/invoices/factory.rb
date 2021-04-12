# frozen_string_literal: true

module Invoices
  class Factory
    BookingFlow.require_rich_text_template(:invoices_deposit_text, context: %i[booking invoice])
    BookingFlow.require_rich_text_template(:invoices_invoice_text, context: %i[booking invoice])
    BookingFlow.require_rich_text_template(:invoices_late_notice_text, context: %i[booking invoice])

    def call(booking, params = {}, supersede_invoice_id = nil)
      invoice = ::Invoice.new(defaults(booking).merge(params))
      invoice.payable_until ||= payable_until(invoice)
      invoice.text ||= rich_text_template(invoice)
      invoice.invoice_parts = supersede_invoice_invoice_parts(invoice, supersede_invoice_id)
      invoice
    end

    private

    def supersede_invoice_invoice_parts(invoice, supersede_invoice_id)
      return [] if supersede_invoice_id.blank?

      supersede_invoice = invoice.booking.organisation.invoices.find(supersede_invoice_id)
      supersede_invoice.invoice_parts.map(&:dup)
    end

    def defaults(booking)
      {
        type: Invoices::Invoice.to_s, issued_at: Time.zone.today, booking: booking,
        payment_info_type: booking.organisation.default_payment_info_type || PaymentInfos::OrangePaymentSlip
      }
    end

    def rich_text_template(invoice)
      key = "#{invoice.model_name.param_key}_text"
      rich_text_template = invoice.organisation.rich_text_templates.by_key(key, home_id: invoice.booking.home_id)
      rich_text_template&.interpolate('invoice' => invoice, 'booking' => invoice.booking)
    end

    def payable_until(invoice)
      return invoice.booking.organisation.long_deadline.from_now if invoice.is_a?(Invoices::Deposit)

      invoice.booking.organisation.payment_deadline.from_now
    end
  end
end
