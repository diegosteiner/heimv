require 'prawn'

module Export
  module Pdf
    class Invoice < Base
      attr_reader :invoice
      delegate :booking, :organisation, to: :invoice

      def initialize(invoice)
        @invoice = invoice
      end

      add_font_family 'ocr', { normal: File.join(FONTS_PATH, 'ocrb', 'webfonts', 'OCR-B-regular-web.ttf') }

      def sections
        heading_sections + [
          InvoiceHeaderSection.new(invoice),
          Base::MarkdownSection.new(Markdown.new(invoice.text)),
          InvoicePartSection.new(invoice),
          payment_info_section
        ]
      end

      def heading_sections
        [
          Base::LogoSection.new(organisation.logo),
          Base::SenderAddressSection.new(booking),
          Base::RecipientAddressSection.new(booking)
        ]
      end

  end
end
