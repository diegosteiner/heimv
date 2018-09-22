require 'prawn'

module Pdf
  class Invoice < BasePdf
    def initialize(invoice)
      @invoice = invoice
      @booking = invoice.booking
      document.font_families.update('ocr' => { normal: ocr_font_path })
    end

    def ocr_font_path
      Rails.root.join('app', 'webpack', 'fonts', 'ocrb', 'webfonts', 'OCR-B-regular-web.ttf')
    end

    def sections
      [
        Sections::HeaderSection.new,
        Sections::SenderAddressSection.new,
        Sections::RecipientAddressSection.new(@booking),
        Sections::TitleSection.new("Rechnung: #{@booking.home.name}"),
        ->(pdf) { pdf.text @invoice.ref },
        Sections::MarkdownSection.new(@invoice.text, InterpolationService.call(@invoice)),
        InvoicePartSection.new(@invoice),
        PaymentSlipSection.new(@invoice)
      ]
    end

    class PaymentSlipSection < Sections::Section
      def initialize(invoice)
        @invoice = invoice
      end

      def call(pdf)
        render_code(pdf)
        render_esr_number(pdf)
      end

      def render_code(pdf)
        pdf.bounding_box([130, -4], width: 395, height: 10.2) do
          pdf.font('ocr', size: 10.2) do
            pdf.text @invoice.payment_slip_code
          end
        end
      end

      def render_esr_number(pdf)
        pdf.bounding_box([295, 147], width: 235, height: 10) do
        pdf.font('ocr', size: 10) do
          pdf.text @invoice.esr_number
        end
      end
    end
    end
  end
end
