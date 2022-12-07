# frozen_string_literal: true

class Invoice
  class Factory
    RichTextTemplate.require_template(:invoices_deposit_text, context: %i[booking invoice], required_by: self)
    RichTextTemplate.require_template(:invoices_invoice_text, context: %i[booking invoice], required_by: self)
    RichTextTemplate.require_template(:invoices_late_notice_text, context: %i[booking invoice], required_by: self)

    def call(booking, params = {})
      ::Invoice.new(defaults(booking).merge(params)).tap do |invoice|
        invoice.payable_until ||= payable_until(invoice)
        invoice.text ||= rich_text_template(invoice)
        invoice.payment_info_type = payment_info_type(invoice)
        prepare_to_supersede(invoice) if invoice.supersede_invoice.present?
      end
    end

    def prepare_to_supersede(invoice)
      supersede_invoice = invoice.supersede_invoice

      invoice.booking ||= supersede_invoice.booking
      invoice.ref ||= supersede_invoice.ref
      invoice.invoice_parts = supersede_invoice.invoice_parts&.map(&:dup)
    end

    def defaults(booking)
      { type: Invoices::Invoice.to_s, issued_at: Time.zone.today, booking: booking }
    end

    def payment_info_type(invoice)
      return if invoice.type.to_s == Invoices::Offer.to_s

      booking = invoice.booking
      country_code = booking.tenant&.country_code&.upcase
      return PaymentInfos::ForeignPaymentInfo if country_code && country_code != booking.organisation.country_code

      booking.organisation.default_payment_info_type || PaymentInfos::QrBill
    end

    def rich_text_template(invoice)
      key = "#{invoice.model_name.param_key}_text"
      booking = invoice.booking
      rich_text_template = invoice.organisation.rich_text_templates.enabled.by_key(key, home_id: booking.home_id)
      I18n.with_locale(invoice.booking.locale) do
        rich_text_template&.interpolate(invoice: invoice, booking: invoice.booking,
                                        home: booking.home, organisation: booking.organisation)&.body
      end
    end

    def payable_until(invoice)
      settings = invoice.booking.organisation.settings
      return settings.deposit_payment_deadline.from_now if invoice.is_a?(Invoices::Deposit)

      settings.invoice_payment_deadline.from_now
    end
  end
end
