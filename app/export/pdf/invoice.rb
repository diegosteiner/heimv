require 'prawn'

module Pdf
  class Invoice < Base
    def initialize(invoice)
      @invoice = invoice
      @booking = invoice.booking
      @payment_slip = PaymentSlip.new(@invoice)
      document.font_families.update('ocr' => { normal: ocr_font_path })
    end

    def ocr_font_path
      Rails.root.join('app', 'webpack', 'fonts', 'ocrb', 'webfonts', 'OCR-B-regular-web.ttf')
    end

    # rubocop:disable Metrics/AbcSize
    def sections
      [
        Base::LogoSection.new, Base::SenderAddressSection.new,
        Base::RecipientAddressSection.new(@booking), Base::TitleSection.new("Rechnung: #{@booking.home.name}"),
        ->(pdf) { pdf.text @booking.ref },
        Base::MarkdownSection.new(Markdown.new(@invoice.text)),
        InvoicePartSection.new(@invoice),
        (print_payment_slip? ? PaymentSlipSection.new(@payment_slip) : PaymentInformationSection.new(@payment_slip))
      ]
    end
    # rubocop:enable Metrics/AbcSize

    def print_payment_slip?
      @invoice.print_payment_slip
    end
  end
end
