# frozen_string_literal: true

module Invoices
  class Factory
    BookingStrategy.require_markdown_template(:invoices_deposit_text, context: %i[booking invoice])
    BookingStrategy.require_markdown_template(:invoices_invoice_text, context: %i[booking invoice])
    BookingStrategy.require_markdown_template(:invoices_late_notice_text, context: %i[booking invoice])

    def call(booking, params)
      invoice = ::Invoice.new(default_attributes.merge(booking: booking).merge(params || {}))
      invoice.payable_until ||= payable_until(invoice)
      invoice.text ||= markdown_template(invoice)
      invoice
    end

    private

    def default_attributes
      { type: Invoices::Invoice.to_s, payment_info_type: PaymentInfos::OrangePaymentSlip }
    end

    def markdown_template(invoice)
      key = "#{invoice.model_name.param_key}_text"
      markdown_template = invoice.organisation.markdown_templates.by_key(key, home_id: invoice.booking.home_id)
      markdown_template&.interpolate('invoice' => invoice, 'booking' => invoice.booking)
    end

    def payable_until(invoice)
      return invoice.booking.organisation.long_deadline.from_now if invoice.is_a?(Invoices::Deposit)

      invoice.booking.organisation.payment_deadline.from_now
    end
  end
end
