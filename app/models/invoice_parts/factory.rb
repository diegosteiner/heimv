module InvoiceParts
  class Factory
    def suggest(invoice, invoice_parts = invoice.invoice_parts)
      invoice.booking.usages.where.not(id: invoice_parts.map(&:usage_id)).map { |usage| from_usage(invoice, usage) } +
        [from_deposit(invoice)]
    end

    def label_2(usage)
      [
        format_used_units(usage.used_units),
        format_unit(usage.tarif.unit),
        format_price_per_unit(usage.tarif.price_per_unit)
      ].join
    end

    def from_usage(invoice, usage)
      InvoiceParts::Add.new(
        apply: invoice.new_record? && invoice.type.to_sym == usage.tarif.invoice_type.to_sym,
        usage: usage,
        label: usage.tarif.label,
        label_2: label_2(usage),
        position: usage.tarif.position,
        amount: usage.price
      )
    end

    def from_deposit(invoice, deposits = invoice.booking.invoices.deposit)
      InvoiceParts::Add.new(
        apply: invoice.new_record? && invoice.is_a?(Invoices::Invoice),
        label: Invoices::Deposit.model_name.human,
        amount: - deposits.sum(&:amount_paid)
      )
    end

    protected

    def format_used_units(used_units)
      return unless used_units

      format('%<used_units_rounded>g × ', used_units_rounded: format('%<used_units>.2f', used_units: used_units))
    end

    def format_unit(unit)
      return unless unit

      format('%<unit>s', unit: unit)
    end

    def format_price_per_unit(price_per_unit)
      return unless price_per_unit

      format(' à CHF %<price_per_unit_rounded>g', price_per_unit_rounded: format('%<price>.2f', price: price_per_unit))
    end
  end
end
