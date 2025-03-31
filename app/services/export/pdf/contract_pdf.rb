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
        header_text = I18n.t('contracts.header_reference', ref: @booking.ref)
        render Renderables::PageHeader.new(text: header_text, logo: @organisation.logo)
      end

      to_render do
        represented_by = @organisation.representative_address.presence
        address = if represented_by
                    [@organisation.name]
                  else
                    [@organisation.address]
                  end

        render Renderables::Address.new(address, represented_by:, label: Contract.human_attribute_name('issuer'))
      end

      to_render do
        tenant_organisation = @booking.tenant_organisation
        tenant_address_lines = @booking.tenant&.full_address_lines

        if tenant_organisation
          address = tenant_organisation
          represented_by = tenant_address_lines
        else
          address = tenant_address_lines
          represented_by = nil
        end

        render Renderables::Address.new(address, represented_by:, column: :right, label: Tenant.model_name.human)
      end

      to_render do
        special_tokens = { TARIFS: -> { render_tarifs_table } }
        Renderables::RichText.split(@contract.text, special_tokens).each { render it }
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

      to_render do
        number_pages I18n.t('contracts.page_numbering', page: '<page>', total: '<total>'),
                     at: [bounds.right - 50, -20], align: :right, size: font_size
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
