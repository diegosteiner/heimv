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
        render Renderables::Logo.new(@organisation.logo)
        render Renderables::AddressedHeader.new(@booking)
        render Renderables::Markdown.new(@offer.text)
      end

      to_render do
        next if usages.blank?

        move_down 10
        table(tarif_table_data, width: bounds.width) do
          rows(0).style(font_style: :bold)
          cells.style(borders: [], padding: [0, 0, 4, 0])
          column([2, 3, 4]).style(align: :right)
        end
      end

      to_render do
        bounding_box([0, cursor + 20], width: bounds.width) do
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
        [tarif_table_headers] +
          usages.map do |usage|
            [
              usage.tarif.label,
              usage.tarif.unit,
              format('CHF %<price>.2f', price: usage.tarif.price_per_unit),
              usage.presumed_used_units,
              format('CHF %<price>.2f', price: usage.presumed_price)
            ]
          end
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
