# frozen_string_literal: true

class Invoice
  class ItemFactory
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
        ].flatten.compact
      end
    end

    protected

    def from_usages(usages = booking.usages.ordered.where.not(id: invoice.items.map(&:usage_id)))
      usages.group_by(&:tarif_group).filter_map do |group, grouped_usages|
        items_group = usages_to_items(grouped_usages)
        next unless items_group.any?

        title = usage_group_to_item(group, items_group)
        [title, items_group]
      end.flatten
    end

    def from_unassigned_payments # rubocop:disable Metrics/MethodLength
      unassigned_payments = booking.payments.where(invoice: nil, write_off: false)
      payed_amount = unassigned_payments.sum(:amount)
      return [] unless payed_amount.positive? && invoice.new_record?

      apply = invoice.items.none?

      [
        ::Invoice::Items::Deposit.new(apply:, label: I18n.t('items.unassigned_payments_amount'),
                                      amount: - payed_amount, reassign_payments: unassigned_payments,
                                      vat_category_id: organisation.accounting_settings.rental_yield_vat_category_id,
                                      accounting_account_nr: organisation.accounting_settings.rental_yield_account_nr,
                                      accounting_cost_center_nr: :home, parent: invoice)
      ]
    end

    def from_deposits # rubocop:disable Metrics/AbcSize
      deposited_payments = Payment.joins(:invoice).where(invoice: { type: Invoices::Deposit.sti_name,
                                                                    discarded_at: nil }, booking:, write_off: false)
      deposited_amount = deposited_payments.sum(:amount)
      return [] unless deposited_amount.positive? && invoice.new_record? && invoice.is_a?(Invoices::Invoice)

      apply = invoice.items.none?

      [::Invoice::Items::Title.new(apply:, label: Invoices::Deposit.model_name.human, parent: invoice),
       ::Invoice::Items::Deposit.new(apply:, label: I18n.t('items.deposited_amount'), amount: - deposited_amount,
                                     vat_category_id: organisation.accounting_settings.rental_yield_vat_category_id,
                                     accounting_account_nr: organisation.accounting_settings.rental_yield_account_nr,
                                     accounting_cost_center_nr: :home, parent: invoice)]
    end

    def from_supersede_invoice
      @invoice.supersede_invoice&.items&.map(&:dup) if @invoice.new_record?
    end

    def usages_to_items(usages)
      usages.flat_map do |usage|
        next unless usage.tarif&.associated_types&.include?(Tarif::ASSOCIATED_TYPES.key(invoice.class))

        case usage.tarif
        when Tarifs::OvernightStay
          overnight_stay_usage_to_item(usage)
        else
          default_usage_to_item(usage)
        end
      end.compact
    end

    def overnight_stay_usage_to_item(usage)
      breakdown = usage.booking.dates.filter_map do |date|
        amount = usage.details&.fetch(date.iso8601, nil)
        next if amount.blank?

        [
          I18n.l(date),
          ActiveSupport::NumberHelper.number_to_rounded(amount, precision: 2, strip_insignificant_zeros: true)
        ].join(': ')
      end.join("\n").presence

      apply = usage.booking.organisation.settings.invoice_show_usage_details
      [default_usage_to_item(usage),
       (::Invoice::Items::Text.new(label: '', apply:, breakdown:, parent: invoice) if breakdown)]
    end

    def default_usage_to_item(usage)
      apply = invoice.items.none? && usage.tarif.apply_usage_to_invoice?(usage, invoice)
      tarif = usage.tarif
      ::Invoice::Items::Add.new(usage: usage, apply:, label: tarif.label, vat_category: tarif.vat_category,
                                breakdown: usage.remarks.presence || usage.breakdown,
                                amount: usage.price, accounting_account_nr: tarif.accounting_account_nr,
                                accounting_cost_center_nr: tarif.accounting_cost_center_nr, parent: invoice)
    end

    def usage_group_to_item(group, group_usages)
      apply = group.present? && group_usages.any?(&:apply)
      ::Invoice::Items::Title.new(label: group, apply:)
    end
  end
end
