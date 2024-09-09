# frozen_string_literal: true

class Invoice
  class Factory
    RichTextTemplate.define(:invoices_deposit_text, context: %i[booking invoice])
    RichTextTemplate.define(:invoices_invoice_text, context: %i[booking invoice])
    RichTextTemplate.define(:invoices_offer_text, context: %i[booking invoice])
    RichTextTemplate.define(:invoices_late_notice_text, context: %i[booking invoice])

    def call(booking, params = {}) # rubocop:disable Metrics/AbcSize
      ::Invoice.new(defaults(booking).merge(params)).tap do |invoice|
        I18n.with_locale(invoice.locale) do
          invoice.payment_info_type = payment_info_type(invoice)
          invoice.payable_until ||= payable_until(invoice)
          invoice.payment_required = payment_required(invoice)
          invoice.text ||= text_from_template(invoice)
          prepare_to_supersede(invoice) if invoice.supersede_invoice.present?
        end
      end
    end

    def prepare_to_supersede(invoice)
      supersede_invoice = invoice.supersede_invoice

      invoice.booking ||= supersede_invoice.booking
      invoice.ref ||= supersede_invoice.ref
    end

    def defaults(booking)
      {
        type: Invoices::Invoice.to_s, issued_at: Time.zone.today,
        booking:, locale: booking.locale || I18n.locale
      }
    end

    protected

    def payment_info_type(invoice)
      return if invoice.type.to_s == Invoices::Offer.to_s

      booking = invoice.booking
      country_code = booking.tenant&.country_code&.upcase
      return PaymentInfos::ForeignPaymentInfo if country_code && country_code != booking.organisation.country_code

      booking.organisation.default_payment_info_type || PaymentInfos::QrBill
    end

    def text_from_template(invoice)
      key = "#{invoice.model_name.param_key}_text"
      rich_text_template = invoice.organisation.rich_text_templates.enabled.by_key(key)
      return if rich_text_template.blank?

      rich_text_template.interpolate(template_context(invoice)).body
    end

    def template_context(invoice)
      TemplateContext.new(
        invoice:, booking: invoice.booking,
        costs: CostEstimation.new(invoice.booking),
        organisation: invoice.booking.organisation
      )
    end

    def payable_until(invoice)
      return invoice.booking.begins_at if invoice.payment_info.is_a?(PaymentInfos::OnArrival)

      settings = invoice.booking.organisation.settings
      if invoice.is_a?(Invoices::Deposit)
        return [settings.deposit_payment_deadline.from_now,
                invoice.booking.begins_at].min
      end

      settings.invoice_payment_deadline.from_now
    end

    def payment_required(invoice)
      return false if invoice.payment_info.is_a?(PaymentInfos::OnArrival)
      return true if invoice.booking.past?

      deadline = invoice.booking.begins_at - (invoice.booking.organisation.settings.upcoming_soon_window || 0)
      deadline > (payable_until(invoice) || Time.zone.now)
    end
  end
end
