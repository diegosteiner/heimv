# frozen_string_literal: true

class Invoice
  class Factory
    RichTextTemplate.define(:invoices_deposit_text, context: %i[booking invoice])
    RichTextTemplate.define(:invoices_invoice_text, context: %i[booking invoice])
    RichTextTemplate.define(:invoices_offer_text, context: %i[booking invoice])
    RichTextTemplate.define(:invoices_late_notice_text, context: %i[booking invoice])

    def initialize(booking)
      @booking = booking
    end

    def build(attributes = {})
      ::Invoice.new(defaults.merge(attributes)).tap do |invoice|
        invoice.payment_info_type = payment_info_type(invoice)
        invoice.payable_until ||= payable_until(invoice)
        invoice.payment_required = payment_required(invoice)
        invoice.text ||= text_from_template(invoice)
        prepare_to_supersede(invoice) if invoice.supersede_invoice.present?
      end
    end

    def defaults
      {
        type: Invoices::Invoice.to_s, issued_at: Time.zone.today,
        booking: @booking, locale: @booking.locale || I18n.locale
      }
    end

    protected

    def prepare_to_supersede(invoice)
      supersede_invoice = invoice.supersede_invoice

      invoice.booking ||= supersede_invoice.booking
      invoice.payment_ref ||= supersede_invoice.payment_ref
    end

    def payment_info_type(invoice)
      return if invoice.type.to_s == Invoices::Offer.to_s

      booking = invoice.booking
      country_code = booking.tenant&.country_code&.upcase
      return PaymentInfos::ForeignPaymentInfo if country_code && country_code != booking.organisation.country_code

      booking.organisation.default_payment_info_type || PaymentInfos::QrBill
    end

    def text_from_template(invoice)
      key = "#{invoice.model_name.param_key}_text"
      invoice.organisation.rich_text_templates.enabled.by_key(key)
             &.interpolate(template_context(invoice), locale: invoice.locale)
             &.body
    end

    def template_context(invoice)
      TemplateContext.new(
        invoice:, booking: invoice.booking,
        costs: CostEstimation.new(invoice.booking),
        organisation: invoice.booking.organisation
      )
    end

    def payable_until(invoice)
      booking = invoice.booking
      return booking.begins_at if invoice.payment_info.is_a?(PaymentInfos::OnArrival)

      if invoice.is_a?(Invoices::Deposit)
        return [booking.organisation.deadline_settings.deposit_payment_deadline.from_now, booking.begins_at].min
      end

      booking.organisation.deadline_settings.invoice_payment_deadline.from_now
    end

    def payment_required(invoice)
      return false if invoice.payment_info.is_a?(PaymentInfos::OnArrival)
      return true if invoice.booking.past?

      deadline = invoice.booking.begins_at - (invoice.booking.organisation.settings.upcoming_soon_window || 0)
      deadline > (payable_until(invoice) || Time.zone.now)
    end
  end
end
