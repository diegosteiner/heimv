require 'prawn'

class InvoicePdf < AddressedPdf
  def initialize(invoice)
    @invoice = invoice
    @booking = invoice.booking
    @title = "Rechnung: #{@booking.home.name}"
  end

  part :body do
    text @invoice.ref
    move_down 10
    markdown = MarkdownService.new(@invoice.text)
    markdown.pdf_body(InterpolationService.call(@invoice)).each do |body|
      text body.delete(:text), body.reverse_merge(inline_format: true, size: 10)
    end
    move_down 20
  end

  part :invoice_parts do
    table_data = @invoice.invoice_parts.map do |invoice_part|
      [invoice_part.label, invoice_part.label_2, format('CHF %.2f', invoice_part.amount)]
    end
    table_data << ['Total', '', format('CHF %.2f', @invoice.amount)]

    table table_data, column_widths: [200, 200, 94], cell_style: { borders: [] } do
      cells.style(size: 10)
      column(2).style(align: :right)
      row(-1).style(borders: [:top], font_style: :bold)
    end
  end
end
