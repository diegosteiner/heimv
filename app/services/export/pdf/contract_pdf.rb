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
        render Renderables::PageHeader.new(text: @booking.ref, logo: @organisation.logo)
        render Renderables::AddressedHeader.new(@booking, recipient_address: @booking.tenant.contact_lines)
        render Renderables::RichText.new(@contract.text)
      end

      to_render do
        next if tarifs.blank?

        move_down 10
        table(tarif_table_data, width: bounds.width) do
          rows(0).style(font_style: :bold)
          cells.style(borders: [], padding: [0, 0, 4, 0])
          column(2).style(align: :right)
        end
      end

      to_render do
        bounding_box([0, cursor - 20], width: bounds.width) do
          issuer_signature_label = I18n.t('contracts.issuer_signature_label')
          render Renderables::Signature.new(issuer_signature_label, signature_image: @organisation.contract_signature,
                                                                    date: @contract.valid_from,
                                                                    location: @organisation.location)

          tenant_signature_label = I18n.t('contracts.tenant_signature_label')
          render Renderables::Signature.new(tenant_signature_label, align: :right)
        end
      end

      def tarifs
        @tarifs ||= @booking.used_tarifs.where(tenant_visible: true)
      end

      def tarif_table_data
        [[Tarif.model_name.human, Tarif.human_attribute_name(:unit), Tarif.human_attribute_name(:price_per_unit)]] +
          tarifs.map do |tarif|
            [tarif.label, tarif.unit, format('CHF %<price>.2f', price: tarif.price_per_unit)]
          end
      end
    end
  end
end
