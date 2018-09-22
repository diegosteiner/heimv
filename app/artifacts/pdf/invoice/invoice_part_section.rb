module Pdf
  class Invoice
    class InvoicePartSection < Sections::Section
      def initialize(invoice)
        @invoice = invoice
      end

      def table_data
        data = @invoice.invoice_parts.map do |invoice_part|
          [invoice_part.label, invoice_part.label_2, format('CHF %.2f', invoice_part.amount)]
        end
        data << ['Total', '', format('CHF %.2f', @invoice.amount)]
      end

      def call(pdf)
        pdf.move_down 20
        pdf.table table_data, column_widths: [200, 200, 94], cell_style: { borders: [] } do
          cells.style(size: 10)
          column(2).style(align: :right)
          row(-1).style(borders: [:top], font_style: :bold)
        end
      end
    end
  end
end
