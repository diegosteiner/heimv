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
      attr_reader :parent

      delegate :booking, :organisation, :invoice_address, to: :parent

      def initialize(parent)
        super()
        @parent = parent
      end

      to_render do
        render Renderables::PageHeader.new(text: parent.ref || booking.ref, logo: organisation.logo)
      end

      to_render do
        address = organisation.creditor_address.presence || organisation.address.presence
        render Renderables::Address.new(address, label: Contract.human_attribute_name('issuer'))
      end

      to_render do
        render Renderables::Address.new(invoice_address.lines,
                                        represented_by: invoice_address.represented_by,
                                        column: :right, label: Tenant.model_name.human)
      end

      to_render do
        next unless parent.is_a?(Invoice)

        font_size(9) do
          text "#{::Invoice.human_attribute_name(:ref)}: #{parent.ref}" if parent.ref.present?
          text "#{::Invoice.human_attribute_name(:sent_at)}: #{I18n.l(parent.sent_at&.to_date || Time.zone.today)}"
          if parent.payable_until
            text "#{::Invoice.human_attribute_name(:payable_until)}: #{I18n.l(parent.payable_until.to_date)}"
          end
          text "#{::Booking.human_attribute_name(:ref)}: #{parent.booking.ref}"
        end
      end

      to_render do
        special_tokens = { TARIFS: -> { render Renderables::Invoice::ItemsTable.new(parent) } }
        slices = Renderables::RichText.split(parent.text, special_tokens)
        slices.each { render it }
      end

      to_render do
        next unless parent.is_a?(Invoice)

        payment_info_renerable = parent.payment_info&.show? &&
                                 PAYMENT_INFOS.fetch(parent.payment_info.class)&.new(parent.payment_info)
        render payment_info_renerable if payment_info_renerable
      end
    end
  end
end
