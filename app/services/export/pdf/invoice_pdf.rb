# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class InvoicePdf < Base
      PAYMENT_INFOS = {
        PaymentInfos::QrBill => Renderables::Invoice::QrBill,
        PaymentInfos::ForeignPaymentInfo => Renderables::Invoice::ForeignPaymentInfo,
        PaymentInfos::TextPaymentInfo => Renderables::Invoice::TextPaymentInfo,
        PaymentInfos::OnArrival => nil
      }.freeze
      attr_reader :invoice

      delegate :booking, :organisation, :payment_info, :invoice_address, to: :invoice

      def initialize(invoice)
        super()
        @invoice = invoice
      end

      to_render do
        header_text = invoice.accounting_ref || booking.ref
        render Renderables::PageHeader.new(text: header_text, logo: organisation.logo)
      end

      to_render do
        address = organisation.creditor_address.presence || organisation.address.presence
        render Renderables::Address.new(address, label: Contract.human_attribute_name('issuer'))
      end

      to_render do
        render Renderables::Address.new(invoice_address.lines,
                                        represented_by: invoice_address.represented_by,
                                        column: :right, label: Tenant.model_name.human)
      end

      to_render do
        next if invoice.is_a?(Invoices::Offer)

        font_size(9) do
          text "#{::Invoice.human_attribute_name(:sent_at)}: #{I18n.l(invoice.sent_at&.to_date || Time.zone.today)}"
          if invoice.payable_until
            text "#{::Invoice.human_attribute_name(:payable_until)}: #{I18n.l(invoice.payable_until.to_date)}"
          end
          text "#{::Booking.human_attribute_name(:ref)}: #{invoice.booking.ref}"
        end
      end

      to_render do
        special_tokens = { TARIFS: Renderables::Invoice::InvoicePartsTable.new(invoice) }
        Renderables::RichText.split(invoice.text, special_tokens).each { render _1 }
      end

      to_render do
        payment_info_renerable = payment_info&.show? && PAYMENT_INFOS.fetch(payment_info.class)&.new(payment_info)
        render payment_info_renerable if payment_info_renerable
      end
    end
  end
end
