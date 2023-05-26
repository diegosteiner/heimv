# frozen_string_literal: true

class InvoicePart
  class Factory
    attr_reader :invoice

    delegate :booking, to: :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def call
      from_usages + from_deposits
    end

    def from_usages
      usages = booking.usages.ordered.where.not(id: invoice.invoice_parts.map(&:usage_id))
      invoice_parts = []
      usages.group_by(&:tarif_group).each do |group, grouped_usages|
        invoice_parts_group = usages_to_invoice_parts(grouped_usages, invoice_parts.count)
        title = usage_group_to_invoice_part(group, invoice_parts_group, invoice_parts.count)
        invoice_parts += [title, invoice_parts_group].flatten
      end
      invoice_parts
    end

    def from_deposits
      deposits = Invoices::Deposit.of(@invoice.booking).kept
      deposited_amount = deposits.sum(&:amount_paid)
      return [] unless deposited_amount.positive? && @invoice.new_record? &&
                       !@invoice.is_a?(Invoices::Offer)

      apply = suggest?
      [
        InvoiceParts::Text.new(apply: apply, label: Invoices::Deposit.model_name.human),
        InvoiceParts::Add.new(apply: apply, label: Invoices::Deposit.model_name.human, amount: - deposited_amount)
      ]
    end

    def usages_to_invoice_parts(usages, position_cursor = 0)
      usages.map do |usage|
        invoice_type_match = usage.tarif&.associated_types&.include?(Tarif::ASSOCIATED_TYPES.key(invoice.class))
        apply = suggest? && invoice_type_match
        InvoiceParts::Add.from_usage(usage, apply: apply, ordinal_position: (position_cursor += 1))
      end
    end

    def usage_group_to_invoice_part(group, group_usages, position_cursor = 0)
      InvoiceParts::Text.new(label: group, ordinal_position: position_cursor, apply: group_usages.any?(&:apply))
    end

    def suggest?
      invoice.invoice_parts.none?
    end
  end
end
