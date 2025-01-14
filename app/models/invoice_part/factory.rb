# frozen_string_literal: true

class InvoicePart
  class Factory
    attr_reader :invoice

    delegate :booking, :organisation, to: :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def build
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
                                  amount: - payed_amount, reassign_payments: unassigned_payments,
                                  vat_category_id: organisation.accounting_settings.rental_yield_vat_category_id,
                                  accounting_account_nr: organisation.accounting_settings.rental_yield_account_nr,
                                  accounting_cost_center_nr: :home)
      ]
    end

    def from_deposits # rubocop:disable Metrics/AbcSize
      deposited_payments = Payment.joins(:invoice).where(invoice: { type: Invoices::Deposit.sti_name,
                                                                    discarded_at: nil }, booking:, write_off: false)
      deposited_amount = deposited_payments.sum(:amount)
      return [] unless deposited_amount.positive? && invoice.new_record? && invoice.is_a?(Invoices::Invoice)

      apply = invoice.invoice_parts.none?

      [InvoiceParts::Title.new(apply:, label: Invoices::Deposit.model_name.human),
       InvoiceParts::Deposit.new(apply:, label: I18n.t('invoice_parts.deposited_amount'), amount: - deposited_amount,
                                 vat_category_id: organisation.accounting_settings.rental_yield_vat_category_id,
                                 accounting_account_nr: organisation.accounting_settings.rental_yield_account_nr,
                                 accounting_cost_center_nr: :home)]
    end

    def from_supersede_invoice
      @invoice.supersede_invoice&.invoice_parts&.map(&:dup) if @invoice.new_record?
    end

    def usages_to_invoice_parts(usages)
      usages.flat_map do |usage|
        next unless usage.tarif&.associated_types&.include?(Tarif::ASSOCIATED_TYPES.key(invoice.class))

        case usage.tarif
        when Tarifs::OvernightStay
          overnight_stay_usage_to_invoice_part(usage)
        else
          default_usage_to_invoice_part(usage)
        end
      end.compact
    end

    def overnight_stay_usage_to_invoice_part(usage)
      breakdown = usage.booking.dates.filter_map do |date|
        amount = usage.details&.fetch(date.iso8601, nil)
        next if amount.blank?

        [
          I18n.l(date),
          ActiveSupport::NumberHelper.number_to_rounded(amount, precision: 2, strip_insignificant_zeros: true)
        ].join(': ')
      end.join("\n").presence

      apply = usage.booking.organisation.settings.invoice_show_usage_details
      [default_usage_to_invoice_part(usage), (InvoiceParts::Text.new(label: '', apply:, breakdown:) if breakdown)]
    end

    def default_usage_to_invoice_part(usage) # rubocop:disable Metrics/AbcSize
      apply = invoice.invoice_parts.none? && usage.tarif.apply_usage_to_invoice?(usage, invoice)
      usage.instance_eval do
        InvoiceParts::Add.new(usage: self, apply:, label: tarif.label, ordinal: tarif.ordinal,
                              vat_category: tarif.vat_category, breakdown: remarks.presence || breakdown,
                              amount: price, accounting_account_nr: tarif.accounting_account_nr,
                              accounting_cost_center_nr: tarif.accounting_cost_center_nr)
      end
    end

    def usage_group_to_invoice_part(group, group_usages)
      apply = group.present? && group_usages.any?(&:apply)
      InvoiceParts::Title.new(label: group, apply:)
    end
  end
end
