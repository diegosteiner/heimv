module Invoices
  class Factory
    def call(booking, params)
      invoice = ::Invoice.new({ booking: booking }.merge(params || {}))
      invoice.text ||= markdown_template(invoice)
      invoice.payable_until ||= payable_until(invoice)
      invoice
    end

    private

    def markdown_template(invoice)
      template_key = "#{invoice.model_name.param_key}_invoice_text"
      MarkdownTemplate[template_key] % @booking
    end

    def payable_until(_invoice)
      30.days.from_now unless @invoice.is_a?(Invoices::Deposit)
    end
  end
end
