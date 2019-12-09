require 'prawn'

module Export
  module Pdf
    class Invoice < Base
      attr_reader :invoice
      delegate :booking, :organisation, to: :invoice

      def initialize(invoice)
        @invoice = invoice
      end

      def initialize_font
        super
        ocr_font_path = File.join(FONTS_PATH, 'ocrb', 'webfonts', 'OCR-B-regular-web.ttf')
        @document.font_families.update('ocr' => { normal: ocr_font_path })
      end

      def sections
        [
          Base::LogoSection.new(organisation.logo),
          Base::SenderAddressSection.new(organisation.address),
          Base::RecipientAddressSection.new(booking),
          Base::MarkdownSection.new(Markdown.new(invoice.text)),
          InvoicePartSection.new(invoice),
          payment_info_section
        ]
      end

      def payment_info_section
        payment_info = @invoice.payment_info
        case payment_info
        when PaymentInfos::OrangePaymentSlip
          OrangePaymentSlipSection.new(payment_info)
        when PaymentInfos::TextPaymentInfo
          TextPaymentInfoSection.new(payment_info)
        end
      end
    end
  end
end
