# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class ContractPdf < Base
      def initialize(contract)
        super()
        @contract = contract
        @booking = contract.booking
        @organisation = @booking.organisation
      end

      to_render do
        header_text = "#{Booking.human_model_name} #{@booking.ref}"
        render Renderables::PageHeader.new(text: header_text, logo: @organisation.logo)
        render Renderables::AddressedHeader.new(@booking, recipient_address: @booking.tenant&.contact_lines)
      end

      to_render do
        special_tokens = { TARIFS: -> { render_tarifs_table } }
        Renderables::RichText.split(@contract.text, special_tokens).each { render _1 }
      end

      to_render do
        start_new_page if cursor < 82
        bounding_box([0, cursor - 20], width: bounds.width, height: 82) do
          issuer_signature_label = I18n.t('contracts.issuer_signature_label')
          render Renderables::Signature.new(issuer_signature_label, signature_image: @organisation.contract_signature,
                                                                    date: @contract.valid_from,
                                                                    location: @organisation.location)

          tenant_signature_label = I18n.t('contracts.tenant_signature_label')
          render Renderables::Signature.new(tenant_signature_label, align: :right)
        end
      end

      def render_tarifs_table
        return if @contract.usages.none?

        move_down 10
        table(tarif_table_data, width: bounds.width) do
          rows(0).style(font_style: :bold)
          cells.style(borders: [], padding: [0, 0, 4, 0])
          columns([2, 3]).style(align: :right)
        end
        move_down 10
      end

      def tarif_table_data
        [[Tarif.model_name.human, Tarif.human_attribute_name(:unit), Tarif.human_attribute_name(:price_per_unit)]] +
          @contract.usages.map do |usage|
            tarif = usage.tarif
            price_per_unit = usage.price_per_unit || usage.price || 0
            [tarif.label, tarif.unit, number_to_currency(price_per_unit, unit: @organisation.currency)]
          end
      end
    end
  end
end
