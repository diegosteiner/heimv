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

      delegate :booking, :organisation, :payment_info, to: :invoice

      def initialize(invoice)
        super()
        @invoice = invoice
      end

      add_font_family 'ocr', normal: File.join(FONTS_PATH, 'ocrb', 'webfonts', 'OCR-B-regular-web.ttf')

      to_render do
        header_text = "#{Booking.human_model_name} #{booking.ref}"
        render Renderables::PageHeader.new(text: header_text, logo: organisation.logo)
        render Renderables::AddressedHeader.new(booking, issuer_address: booking.organisation.creditor_address,
                                                         recipient_address: booking.invoice_address.presence)
      end

      to_render do
        next if invoice.is_a?(Invoices::Offer)

        font_size(9) do
          text "#{::Booking.human_attribute_name(:ref)}: #{invoice.booking.ref}"
          text "#{::Invoice.human_attribute_name(:sent_at)}: #{I18n.l(invoice.sent_at&.to_date || Time.zone.today)}"
          next unless invoice.payable_until

          text "#{::Invoice.human_attribute_name(:payable_until)}: #{I18n.l(invoice.payable_until.to_date)}"
        end
      end

      to_render do
        render Renderables::RichText.new(invoice.text)
        move_down 20
        render Renderables::Invoice::InvoicePartsTable.new(invoice)
      end

      to_render do
        next if invoice.vat.none?

        move_down 20
        vat_data = invoice.vat.map do |vat_percentage, vat_amount|
          [
            I18n.t('invoices.vat_label', vat: vat_percentage),
            organisation.currency,
            ActionController::Base.helpers.number_to_currency(vat_amount, unit: '')
          ]
        end
        font_size(7) do
          text I18n.t('invoices.vat_title')
          table(vat_data, { cell_style: { borders: [], padding: [0, 4, 4, 0] } }) do
            column(2).style(align: :right)
          end
        end
      end

      to_render do
        render PAYMENT_INFOS.fetch(payment_info.class)&.new(payment_info) if payment_info
      end
    end
  end
end
