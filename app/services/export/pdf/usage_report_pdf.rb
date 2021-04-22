# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class UsageReportPdf < Base
      RichTextTemplate.require_template(:usage_report_text, %i[booking], self)
      attr_reader :booking

      delegate :usages, :organisation, to: :booking

      def initialize(booking)
        super()
        @booking = booking
      end

      to_render do
        render Renderables::Logo.new(organisation.logo)
        render Renderables::AddressedHeader.new(booking, recipient_address: booking.tenant.contact_lines)
      end

      to_render do
        rich_text_template = organisation.rich_text_templates.by_key(:usage_report_text, home_id: booking.home_id)
        render Renderables::Markdown.new(rich_text_template.interpolate('booking' => booking)) if rich_text_template
      end

      to_render do
        next if usages.blank?

        move_down 10
        table(tarif_table_data, width: bounds.width, column_widths: { 3 => 150 }) do
          rows(0).style(font_style: :bold)
          cells.style(borders: %i[left right top bottom], padding: [10, 4, 10, 4])
          column([2, 3, 4]).style(align: :right)
        end
      end

      to_render do
        move_down 10
        table([[Usage.human_attribute_name(:remarks)], [nil]], width: bounds.width) do
          rows(0).style(font_style: :bold)
          cells.style(borders: %i[left right top bottom], padding: [10, 4, 10, 4])
          rows([1]).style(height: 100)
        end
      end

      to_render do
        bounding_box([0, cursor - 20], width: bounds.width) do
          issuer_signature_label = I18n.t('contracts.issuer_signature_label')
          render Renderables::Signature.new(issuer_signature_label, signature_image: organisation.contract_signature,
                                                                    location: organisation.location)

          tenant_signature_label = I18n.t('contracts.tenant_signature_label')
          render Renderables::Signature.new(tenant_signature_label, align: :right)
        end
      end

      def tarif_table_data
        [tarif_table_headers] + usages.map { |usage| usage_row_data(usage) } + 3.times.map { usage_row_data(nil) }
      end

      def usage_row_data(usage)
        return [' '] * 4 unless usage

        [
          usage.tarif.label,
          usage.tarif.unit,
          format('CHF %<price>.2f', price: usage.tarif.price_per_unit),
          usage.used_units.presence
        ]
      end

      def tarif_table_headers
        [
          Tarif.model_name.human,
          Tarif.human_attribute_name(:unit),
          Tarif.human_attribute_name(:price_per_unit),
          Usage.human_attribute_name(:used_units)
          # Usage.human_attribute_name(:price)
        ]
      end
    end
  end
end
