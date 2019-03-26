module InvoiceParts
  class Factory
    def suggest(invoice, invoice_parts = invoice.invoice_parts)
      [from_deposit(invoice)] +
        invoice.booking.usages.where.not(id: invoice_parts.map(&:usage_id)).map { |usage| from_usage(invoice, usage) }
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
        apply: invoice.invoice_type == usage.tarif.invoice_type,
        usage: usage,
        label: usage.tarif.label,
        label_2: label_2(usage),
        amount: usage.price
      )
    end

    def from_deposit(invoice, deposits = invoice.booking.invoices.deposit)
      InvoiceParts::Add.new(
        apply: invoice.invoice_type&.to_sym == :invoice,
        label: I18n.t(:'activerecord.enums.invoice.invoice_type.deposit'),
        amount: - deposits.sum(&:amount_paid)
      )
    end

    protected

    def format_used_units(used_units)
      return unless used_units

      format('%<used_units>g × ', used_units: format('%.2f', used_units))
    end

    def format_unit(unit)
      return unless unit

      format('%<unit>s', unit: unit)
    end

    def format_price_per_unit(price_per_unit)
      return unless price_per_unit

      format(' à CHF %<price_per_unit>g', price_per_unit: format('%.2f', price_per_unit))
    end
  end
end
