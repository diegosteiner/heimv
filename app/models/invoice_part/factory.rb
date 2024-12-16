# frozen_string_literal: true

class InvoicePart
  class Factory
    attr_reader :invoice

    delegate :booking, :organisation, to: :invoice
    delegate :accounting_settings, to: :organisation

    def initialize(invoice)
      @invoice = invoice
    end

    def call
      I18n.with_locale(invoice.locale || I18n.locale) do
        [
          from_unassigned_payments.presence,
          from_deposits.presence,
          from_supersede_invoice.presence,
          from_usages.presence
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

    def from_unassigned_payments # rubocop:disable Metrics/MethodLength
      unassigned_payments = booking.payments.where(invoice: nil, write_off: false)
      payed_amount = unassigned_payments.sum(:amount)
      return [] unless payed_amount.positive? && invoice.new_record?

      apply = invoice.invoice_parts.none?

      [
        InvoiceParts::Deposit.new(apply:, label: I18n.t('invoice_parts.unassigned_payments_amount'),
                                  amount: - payed_amount, unassigned_payments:,
                                  vat_category_id: accounting_settings.rental_yield_vat_category_id,
                                  accounting_account_nr: accounting_settings.rental_yield_account_nr,
                                  accounting_cost_center_nr: 9009)
      ]
    end

    def from_deposits # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      deposits = booking.invoices.deposits.kept
      deposited_amount = deposits.sum(&:amount_paid)
      return [] unless deposited_amount.positive? && invoice.new_record? && invoice.is_a?(Invoices::Invoice)

      apply = invoice.invoice_parts.none?

      [
        InvoiceParts::Text.new(apply:, label: Invoices::Deposit.model_name.human),
        InvoiceParts::Deposit.new(apply:, label: I18n.t('invoice_parts.deposited_amount'), amount: - deposited_amount,
                                  vat_category_id: accounting_settings.rental_yield_vat_category_id,
                                  accounting_account_nr: accounting_settings.rental_yield_account_nr,
                                  accounting_cost_center_nr: 9009)
      ]
    end

    def from_supersede_invoice
      @invoice.supersede_invoice&.invoice_parts&.map(&:dup) if @invoice.new_record?
    end

    def usages_to_invoice_parts(usages) # rubocop:disable Metrics/AbcSize
      usages.filter_map do |usage|
        next unless usage.tarif&.associated_types&.include?(Tarif::ASSOCIATED_TYPES.key(invoice.class))

        apply = invoice.invoice_parts.none? && usage.tarif.apply_usage_to_invoice?(usage, invoice)
        usage.instance_eval do
          InvoiceParts::Add.new(usage: self, apply:, label: tarif.label, ordinal: tarif.ordinal,
                                vat_category: tarif.vat_category, breakdown: remarks.presence || breakdown,
                                amount: price, accounting_account_nr: tarif.accounting_account_nr,
                                accounting_cost_center_nr: tarif.accounting_cost_center_nr)
        end
      end
    end

    def usage_group_to_invoice_part(group, group_usages)
      apply = group.present? && group_usages.any?(&:apply)
      InvoiceParts::Text.new(label: group, apply:)
    end
  end
end
