module Pdf
  class Invoice
    class InvoicePartSection < Base::Section
      def initialize(invoice)
        @invoice = invoice
      end

      def table_data
        helpers = ActionController::Base.helpers
        data = @invoice.invoice_parts.map do |invoice_part|
          [invoice_part.label, invoice_part.label_2, helpers.number_to_currency(invoice_part.amount, unit: 'CHF')]
        end
        data << ['Total', '', helpers.number_to_currency(@invoice.amount, unit: 'CHF')]
      end

      def call(pdf)
        pdf.bounding_box([0, 440], width: 494, height: 500) do
          pdf.table table_data, column_widths: [200, 200, 94], cell_style: { borders: [], padding: [0, 4, 4, 0] } do
            cells.style(size: 10)
            column(2).style(align: :right)
            row(-1).style(borders: [:top], font_style: :bold, padding: [4, 4, 4, 0])
          end
        end
      end
    end
  end
end
