# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class OfferPdf < Base
      def initialize(offer)
        super()
        @offer = offer
        @booking = offer.booking
        @organisation = @booking.organisation
      end

      to_render do
        render Renderables::PageHeader.new(text: @booking.ref, logo: @organisation.logo)
        render Renderables::AddressedHeader.new(@booking)
        render Renderables::RichText.new(@offer.text)
      end

      to_render do
        next if usages.blank?

        move_down 20
        table(tarif_table_data,
              column_widths: [nil, 70, 80, 80, 80],
              width: bounds.width,
              cell_style: { borders: [],
                            padding: [0, 4, 4, 0] }) do
          rows(0).style(font_style: :bold)
          column([2, 3, 4]).style(align: :right)
        end
      end

      to_render do
        bounding_box([0, cursor - 30], width: bounds.width) do
          issuer_signature_label = I18n.t('offers.issuer_signature_label')
          render Renderables::Signature.new(issuer_signature_label, signature_image: @organisation.contract_signature,
                                                                    date: @offer.valid_from,
                                                                    location: @organisation.location)
        end
      end

      def usages
        @usages ||= @booking.usages
      end

      def tarif_table_data
        I18n.with_locale(@booking.locale) do
          [tarif_table_headers] + usages.map { |usage| tarif_table_usage_row(usage) }
        end
      end

      def tarif_table_usage_row(usage)
        [
          usage.tarif.label,
          usage.tarif.unit,
          number_to_currency(usage.tarif.price_per_unit || 0, currency: @organisation.currency),
          usage.presumed_used_units,
          number_to_currency(usage.presumed_price || 0, currency: @organisation.currency)
        ]
      end

      def tarif_table_headers
        [
          Tarif.model_name.human,
          Tarif.human_attribute_name(:unit),
          Tarif.human_attribute_name(:price_per_unit),
          Usage.human_attribute_name(:presumed_used_units),
          Usage.human_attribute_name(:presumed_price)
        ]
      end
    end
  end
end
