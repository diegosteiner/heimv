module Export
  module Pdf
    class Invoice
      class InvoicePartSection < Base::Section
        def initialize(invoice)
          @invoice = invoice
        end

        def render
          bounding_box([0, 440], width: 494, height: 500) do
            table table_data,
                  column_widths: [180, 200, 25, 89],
                  cell_style: { borders: [], padding: [0, 4, 4, 0] } do
              cells.style(size: 10)
              column(2).style(align: :right)
              column(3).style(align: :right)
              row(-1).style(borders: [:top], font_style: :bold, padding: [4, 4, 4, 0])
            end
          end
        end

        private

        def table_data
          helpers = ActionController::Base.helpers
          data = @invoice.invoice_parts.map do |invoice_part|
            [invoice_part.label, invoice_part.label_2, 'CHF', helpers.number_to_currency(invoice_part.amount, unit: '')]
          end
          data << ['Total', '', 'CHF', helpers.number_to_currency(@invoice.amount, unit: '')]
        end
      end
    end
  end
end
