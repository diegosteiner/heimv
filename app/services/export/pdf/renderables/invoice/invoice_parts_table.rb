# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      module Invoice
        class InvoicePartsTable < Renderable
          attr_reader :invoice

          delegate :organisation, :invoice_parts, to: :invoice
          delegate :helpers, to: ActionController::Base

          def initialize(invoice)
            @invoice = invoice
            super()
          end

          def render
            move_down 20

            split_invoice_part_groups.each do |group_data|
              move_down 5
              render_invoice_parts_table(group_data)
            end

            move_down 10
            render_invoice_total_table
          end

          def render_invoice_parts_table(invoice_parts_table_data)
            table invoice_parts_table_data, **table_options do
              column(2).style(align: :right)
              column(3).style(align: :right)
            end
          end

          def render_invoice_total_table
            total_data = [[I18n.t('invoices.total'), '', organisation.currency,
                           helpers.number_to_currency(invoice.amount, unit: '')]]

            table total_data, **table_options(borders: [:top], font_style: :bold, padding: [4, 4, 4, 0]) do
              column(2).style(align: :right)
              column(3).style(align: :right)
            end
          end

          protected

          def table_options(**cell_style)
            {
              width: bounds.width,
              column_widths: [190, 207, 27, nil],
              cell_style: { borders: [], padding: [0, 4, 4, 0], valign: :bottom }.merge(cell_style)
            }
          end

          def split_invoice_part_groups(invoice_parts = invoice.invoice_parts)
            [].tap do |groups|
              group ||= []
              invoice_parts.each do |invoice_part|
                next group << invoice_part_table_row_data(invoice_part) unless invoice_part.is_a? ::InvoiceParts::Text

                groups << group if group.any?
                group = [invoice_part_table_row_data(invoice_part)]
              end
              groups << group if group.present?
            end
          end

          def invoice_part_table_row_data(invoice_part)
            case invoice_part
            when ::InvoiceParts::Text
              [{ content: invoice_part.label, font_style: :bold }, '', '', '']
            else
              [invoice_part.label, invoice_part.breakdown, organisation.currency,
               helpers.number_to_currency(invoice_part.calculated_amount, unit: '')]
            end
          end
        end
      end
    end
  end
end
