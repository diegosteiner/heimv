# frozen_string_literal: true

module Invoices
  class Factory
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
      template_key = "#{invoice.model_name.param_key}_text"
      MarkdownTemplate[template_key].interpolate('invoice' => invoice, 'booking' => invoice.booking)
    end

    def payable_until(invoice)
      return invoice.booking.organisation.long_deadline.from_now if invoice.is_a?(Invoices::Deposit)

      invoice.booking.organisation.payment_deadline.from_now
    end
  end
end
