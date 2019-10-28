require 'prawn'

module Export
  module Pdf
    class Invoice < Base
      def initialize(invoice)
        @invoice = invoice
        @booking = invoice.booking
        @payment_slip = PaymentSlip.new(@invoice)
      end

      def initialize_font
        super
        ocr_font_path = File.join(FONTS_PATH, 'ocrb', 'webfonts', 'OCR-B-regular-web.ttf')
        @document.font_families.update('ocr' => { normal: ocr_font_path })
      end

      def sections
        [
          Base::LogoSection.new, Base::SenderAddressSection.new(@booking.organisation.address),
          Base::RecipientAddressSection.new(@booking),
          Base::MarkdownSection.new(Markdown.new(@invoice.text)),
          InvoicePartSection.new(@invoice),
          (print_payment_slip? ? PaymentSlipSection.new(@payment_slip) : PaymentInformationSection.new(@payment_slip))
        ]
      end

      def print_payment_slip?
        @invoice.print_payment_slip
      end
    end
  end
end
