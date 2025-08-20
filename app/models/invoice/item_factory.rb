# frozen_string_literal: true

class Invoice
  class ItemFactory
    attr_reader :parent

    delegate :booking, :organisation, to: :parent

    def initialize(parent)
      @parent = parent
    end

    def build
      I18n.with_locale(parent.locale || I18n.locale) do
        next build_from_usage_groups.compact if parent.is_a?(Quote)

        [
          build_from_deposits.presence,
          build_from_balance.presence,
          build_from_supersede_invoice.presence,
          build_from_usage_groups.presence
        ].flatten.compact
      end
    end

    protected

    def build_from_usage_groups(usages = booking.usages.ordered.where.not(id: parent.items.map(&:usage_id)))
      usages.group_by(&:tarif_group).filter_map do |label, grouped_usages|
        usage_group_items = grouped_usages.map { build_from_usage(it) }.compact
        next unless usage_group_items.any?

        [build_title(label:), usage_group_items]
      end.flatten
    end

    def build_from_balance
      unassigned_payments_amount = booking.payments.where(invoice: nil, write_off: false).sum(:amount) || 0
      deposit_balance = deposits.sum(&:balance) || 0
      amount = deposit_balance - unassigned_payments_amount
      return if amount.zero?

      build_item(class: ::Invoice::Items::Balance, label: I18n.t('invoice_items.balance_breakdown'),
                 amount:, accounting_cost_center_nr: :home,
                 vat_category_id: organisation.accounting_settings.rental_yield_vat_category_id,
                 accounting_account_nr: organisation.accounting_settings.rental_yield_account_nr)
    end

    def build_item(**attributes)
      item_class = attributes.delete(:class) || ::Invoice::Items::Add
      item_class.new(parent:, suggested: true, **attributes)
    end

    def build_title(**attributes)
      build_item(class: ::Invoice::Items::Title, **attributes)
    end

    def deposits
      booking.invoices.deposits.kept.where.not(id: parent.id)
    end

    def build_from_deposits # rubocop:disable Metrics/AbcSize
      return unless deposits.exists?

      [
        build_item(class: ::Invoice::Items::Title, label: Invoices::Deposit.model_name.human(count: 2)),
        deposits.map do |deposit|
          build_item(label: "#{deposit.model_name.human} #{deposit.ref}", breakdown: I18n.l(deposit.issued_at&.to_date),
                     amount: -deposit.amount, accounting_cost_center_nr: :home, deposit_id: deposit.id,
                     vat_category_id: organisation.accounting_settings.rental_yield_vat_category_id,
                     accounting_account_nr: organisation.accounting_settings.rental_yield_account_nr)
        end
      ]
    end

    def build_from_supersede_invoice
      parent.supersede_invoice&.items&.map(&:dup) if parent.new_record?
    end

    def build_from_usage(usage)
      return unless usage.tarif&.associated_types&.include?(Tarif::ASSOCIATED_TYPES.key(parent.class))

      case usage.tarif
      when Tarifs::OvernightStay
        build_from_overnight_stay_usage(usage)
      else
        build_from_default_usage(usage)
      end
    end

    def build_from_overnight_stay_usage(usage)
      breakdown = usage.booking.dates.filter_map do |date|
        amount = usage.details&.fetch(date.iso8601, nil)
        next if amount.blank?

        [
          I18n.l(date),
          ActiveSupport::NumberHelper.number_to_rounded(amount, precision: 2, strip_insignificant_zeros: true)
        ].join(': ')
      end.join("\n").presence

      [build_from_default_usage(usage), (build_item(class: ::Invoice::Items::Text, label: '', breakdown:) if breakdown)]
    end

    def build_from_default_usage(usage)
      build_item(usage:, label: usage.tarif.label, vat_category: usage.tarif.vat_category,
                 breakdown: usage.remarks.presence || usage.breakdown, amount: usage.price,
                 accounting_account_nr: usage.tarif.accounting_account_nr,
                 accounting_cost_center_nr: usage.tarif.accounting_cost_center_nr)
    end
  end
end
