module Invoices
  class Factory
    def call(booking, params)
      invoice = ::Invoice.new(default_attributes.merge(booking: booking).merge(params || {}))
      invoice.text ||= markdown_template(invoice)
      invoice.payable_until ||= payable_until(invoice)
      invoice
    end

    private

    def default_attributes
      { type: Invoices::Invoice.to_s, payment_info_type: PaymentInfos::TextPaymentInfo }
    end

    def markdown_template(invoice)
      template_key = "#{invoice.model_name.param_key}_text"
      MarkdownTemplate[template_key].interpolate('invoice' => invoice, 'booking' => invoice.booking)
    end

    def payable_until(invoice)
      30.days.from_now unless invoice.is_a?(Invoices::Deposit)
    end
  end
end
