# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      module Invoice
        class InvoicePartsTable < Renderable
          attr_reader :invoice

          delegate :organisation, :invoice_parts, to: :invoice
          delegate :number_to_currency, :number_to_percentage, to: ActiveSupport::NumberHelper

          def initialize(invoice)
            @invoice = invoice
            super()
          end

          def render
            render_invoice_parts_table
            render_invoice_total_table
            render_invoice_vat_table
          end

          def render_invoice_parts_table
            invoice_parts_data = invoice_parts.map { invoice_part_table_row_data(_1) }
            return if invoice_parts_data.blank?

            title_indexes = invoice_parts.map.with_index do |invoice_part, index|
              index if invoice_part.is_a?(InvoiceParts::Title)
            end.compact
            table invoice_parts_data, **table_options do
              column(2).style(align: :right)
              column(3).style(align: :right)
              row(title_indexes).padding = [8, 4, 4, 0]
            end
          end

          def render_invoice_total_table
            move_down 10
            total_data = [[I18n.t('invoices.total'), '', organisation.currency,
                           number_to_currency(invoice.amount, unit: '')]]

            table total_data, **table_options(borders: [:top], font_style: :bold) do
              column(2).style(align: :right)
              column(3).style(align: :right)
            end
          end

          def render_invoice_vat_table
            return if invoice.vat_breakdown.none?

            move_down 10
            start_new_page if cursor < (vat_table_data.count + 1) * 9
            font_size(7) do
              text I18n.t('invoices.vat_title')
              table(vat_table_data, { cell_style: { borders: [], padding: [0, 4, 4, 0] } }) do
                column([2, 3]).style(align: :right)
              end
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

          def invoice_part_table_row_data(invoice_part)
            case invoice_part
            when ::InvoiceParts::Title
              [{ content: invoice_part.label, font_style: :bold, padding: [8, 4, 4, 0] }, '', '', '']
            when ::InvoiceParts::Text
              [{ content: invoice_part.label || '' }, { content: invoice_part.breakdown || '' }, '', '']
            else
              [invoice_part.label, invoice_part.breakdown, organisation.currency,
               number_to_currency(invoice_part.calculated_amount, unit: '')]
            end
          end

          def vat_table_data
            invoice.vat_breakdown.map do |vat_category, amount|
              [
                vat_category.label,
                number_to_percentage(vat_category.percentage, precision: 2),
                organisation.currency,
                number_to_currency(amount, unit: ''),
                number_to_currency(vat_category.breakdown(amount)[:vat], unit: '')
              ]
            end
          end
        end
      end
    end
  end
end
