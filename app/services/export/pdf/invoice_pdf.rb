# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class InvoicePdf < Base
      attr_reader :invoice

      delegate :booking, :organisation, to: :invoice

      def initialize(invoice)
        super()
        @invoice = invoice
      end

      add_font_family 'ocr', normal: File.join(FONTS_PATH, 'ocrb', 'webfonts', 'OCR-B-regular-web.ttf')

      to_render do
        render Renderables::PageHeader.new(text: booking.ref, logo: organisation.logo)
        render Renderables::AddressedHeader.new(booking, recipient_address: booking.invoice_address.presence)
      end

      to_render do
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
           helpers.number_to_currency(invoice_part.amount, unit: '')]
        end
        data << ['Total', '', organisation.currency, helpers.number_to_currency(invoice.amount, unit: '')]
      end

      to_render do
        payment_info = invoice.payment_info
        render case payment_info
               when PaymentInfos::QrBill
                 Renderables::Invoice::QrBill.new(payment_info)
               when PaymentInfos::OrangePaymentSlip
                 Renderables::Invoice::OrangePaymentSlip.new(payment_info)
               when PaymentInfos::ForeignPaymentInfo
                 Renderables::Invoice::ForeignPaymentInfo.new(payment_info)
               when PaymentInfos::TextPaymentInfo
                 Renderables::Invoice::TextPaymentInfo.new(payment_info)
               end
      end
    end
  end
end
