# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class InvoicePdf < Base
      PAYMENT_INFOS = {
        PaymentInfos::QrBill => Renderables::Invoice::QrBill,
        PaymentInfos::ForeignPaymentInfo => Renderables::Invoice::ForeignPaymentInfo,
        PaymentInfos::TextPaymentInfo => Renderables::Invoice::TextPaymentInfo,
        PaymentInfos::OnArrival => nil
      }.freeze
      attr_reader :invoice

      delegate :booking, :organisation, :payment_info, to: :invoice

      def initialize(invoice)
        super()
        @invoice = invoice
      end

      to_render do
        header_text = "#{Booking.human_model_name} #{booking.ref}"
        render Renderables::PageHeader.new(text: header_text, logo: organisation.logo)
      end

      to_render do
        address = (organisation.creditor_address || organisation.address)&.lines&.map(&:strip)&.compact_blank
        render Renderables::Address.new(address, label: Contract.human_attribute_name('issuer'))
      end

      to_render do
        tenant_address_lines = booking.tenant&.full_address_lines&.compact_blank
        invoice_address_lines = booking.invoice_address&.lines&.compact_blank

        if booking.tenant_organisation.present? || invoice_address_lines.present?
          address = [booking.tenant_organisation, invoice_address_lines].flatten
          represented_by = invoice_address_lines.present? ? booking.tenant&.name : tenant_address_lines
        else
          address = tenant_address_lines
          represented_by = nil
        end

        render Renderables::Address.new(address, represented_by:, column: :right, label: Tenant.model_name.human)
      end

      to_render do
        next if invoice.is_a?(Invoices::Offer)

        font_size(9) do
          text "#{::Invoice.human_attribute_name(:sent_at)}: #{I18n.l(invoice.sent_at&.to_date || Time.zone.today)}"
          if invoice.payable_until
            text "#{::Invoice.human_attribute_name(:payable_until)}: #{I18n.l(invoice.payable_until.to_date)}"
          end
          text "#{::Booking.human_attribute_name(:ref)}: #{invoice.booking.ref}"
        end
      end

      to_render do
        special_tokens = { TARIFS: Renderables::Invoice::InvoicePartsTable.new(invoice) }
        Renderables::RichText.split(invoice.text, special_tokens).each { render _1 }
      end

      to_render do
        next if invoice.vat.none?

        move_down 20
        start_new_page if cursor < (vat_table_data.count + 1) * 9
        font_size(7) do
          text I18n.t('invoices.vat_title')
          table(vat_table_data, { cell_style: { borders: [], padding: [0, 4, 4, 0] } }) do
            column([2, 3]).style(align: :right)
          end
        end
      end

      to_render do
        render PAYMENT_INFOS.fetch(payment_info.class)&.new(payment_info) if payment_info&.show?
      end

      def vat_table_data
        invoice.vat.map do |vat_percentage, vat_amounts|
          [
            I18n.t('invoices.vat_label', vat: vat_percentage), organisation.currency,
            ActionController::Base.helpers.number_to_currency(vat_amounts[:total], unit: ''),
            ActionController::Base.helpers.number_to_currency(vat_amounts[:tax], unit: '')
          ]
        end
      end
    end
  end
end
