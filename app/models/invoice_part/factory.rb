# frozen_string_literal: true

class InvoicePart
  class Factory
    attr_reader :invoice

    delegate :booking, to: :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def call
      I18n.with_locale(invoice.locale || I18n.locale) do
        [
          from_supersede_invoice.presence,
          from_usages.presence,
          from_deposits.presence
        ].flatten.compact.each_with_index { |invoice_part, i| invoice_part.ordinal_position = i }
      end
    end

    protected

    def from_usages(usages = booking.usages.ordered.where.not(id: invoice.invoice_parts.map(&:usage_id)))
      usages.group_by(&:tarif_group).filter_map do |group, grouped_usages|
        invoice_parts_group = usages_to_invoice_parts(grouped_usages)
        next unless invoice_parts_group.any?

        title = usage_group_to_invoice_part(group, invoice_parts_group)
        [title, invoice_parts_group]
      end.flatten
    end

    def from_deposits
      deposits = Invoices::Deposit.of(@invoice.booking).kept
      deposited_amount = deposits.sum(&:amount_paid)
      return [] unless deposited_amount.positive? && @invoice.new_record? &&
                       !@invoice.is_a?(Invoices::Offer)

      [
        InvoiceParts::Text.new(apply: suggest?, label: Invoices::Deposit.model_name.human),
        InvoiceParts::Add.new(apply: suggest?, label: Invoices::Deposit.model_name.human, amount: - deposited_amount)
      ]
    end

    # def from_vat
    #   usages_grouped_by_vat = booking.usages.filter { |usage| usage.tarif.vat.present? }
    #                                  .group_by { |usage| usage.tarif.vat }
    #   return [] if usages_grouped_by_vat.blank?

    #   [InvoiceParts::Text.new(apply: suggest?, label: I18n.t('invoice_parts.from_vat.title'))] +
    #     usages_grouped_by_vat.map do |vat, usages|
    #       vat_group_to_invoice_parts(vat, usages)
    #     end
    # end

    # def vat_group_to_invoice_parts(vat, usages)
    #   price = usages.sum(&:price)
    #   InvoiceParts::Add.new(apply: suggest?, label: I18n.t('invoice_parts.from_vat.label', vat: vat),
    #                         breakdown: I18n.t('invoice_parts.from_vat.breakdown', vat: vat, price: price),
    #                         amount: (price / 100 * vat))
    # end

    def from_supersede_invoice
      @invoice.supersede_invoice&.invoice_parts&.map(&:dup) if @invoice.new_record?
    end

    def usages_to_invoice_parts(usages)
      usages.filter_map do |usage|
        next unless usage.tarif&.associated_types&.include?(Tarif::ASSOCIATED_TYPES.key(invoice.class))

        apply = suggest? && !usage_already_invoiced?(usage)
        InvoiceParts::Add.from_usage(usage, apply: apply)
      end
    end

    def usage_group_to_invoice_part(group, group_usages)
      InvoiceParts::Text.new(label: group, apply: group.present? && group_usages.any?(&:apply))
    end

    def suggest?
      invoice.invoice_parts.none?
    end

    def usage_already_invoiced?(usage)
      InvoicePart.joins(:invoice).exists?(usage: usage,
                                          invoice: { discarded_at: nil, type: [
                                            Invoices::Deposit.to_s, Invoices::Invoice.to_s
                                          ] })
    end
  end
end
