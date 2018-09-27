require 'prawn'

module Pdf
  class Invoice < Base
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
        Base::LogoSection.new,
        Base::DocumentCodeSection.new('code'),
        Base::SenderAddressSection.new,
        Base::RecipientAddressSection.new(@booking),
        Base::TitleSection.new("Rechnung: #{@booking.home.name}"),
        ->(pdf) { pdf.text @booking.ref },
        Base::MarkdownSection.new(@invoice.text, InterpolationService.call(@invoice)),
        InvoicePartSection.new(@invoice),
        PaymentSlipSection.new(PaymentSlip.new(@invoice))
      ]
    end
  end
end
