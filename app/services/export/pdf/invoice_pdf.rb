# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class InvoicePdf < Base
      PAYMENT_INFOS = {
        PaymentInfos::QrBill => Renderables::Invoice::QrBill,
        PaymentInfos::ForeignPaymentInfo => Renderables::Invoice::ForeignPaymentInfo,
        PaymentInfos::TextPaymentInfo => Renderables::Invoice::TextPaymentInfo
      }.freeze
      attr_reader :invoice

      delegate :booking, :organisation, :payment_info, to: :invoice

      def initialize(invoice)
        super()
        @invoice = invoice
      end

      add_font_family 'ocr', normal: File.join(FONTS_PATH, 'ocrb', 'webfonts', 'OCR-B-regular-web.ttf')

      to_render do
        render Renderables::PageHeader.new(text: booking.ref, logo: organisation.logo)
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
        table invoice_parts_table_data,
              column_widths: [nil, nil, 30, 55],
              width: bounds.width,
              cell_style: { borders: [], padding: [0, 4, 4, 0] } do
          cells.style(size: 10)
          column(2).style(align: :right)
          column(3).style(align: :right)
          row(-1).style(borders: [:top], font_style: :bold, padding: [4, 4, 4, 0])
        end
      end

      def invoice_parts_table_data
        helpers = ActionController::Base.helpers
        data = invoice.invoice_parts.map do |invoice_part|
          [invoice_part.label, invoice_part.breakdown, organisation.currency,
           helpers.number_to_currency(invoice_part.calculated_amount, unit: '')]
        end
        data << ['Total', '', organisation.currency, helpers.number_to_currency(invoice.amount, unit: '')]
      end

      to_render do
        render PAYMENT_INFOS.fetch(payment_info.class)&.new(payment_info) if payment_info
      end

      to_render do
        next unless invoice.is_a?(Invoices::Offer)

        bounding_box([0, cursor - 30], width: bounds.width) do
          issuer_signature_label = I18n.t('contracts.issuer_signature_label')
          render Renderables::Signature.new(issuer_signature_label, signature_image: organisation.contract_signature,
                                                                    date: invoice.issued_at,
                                                                    location: organisation.location)
        end
      end
    end
  end
end
