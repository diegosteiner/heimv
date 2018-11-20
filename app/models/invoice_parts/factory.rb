module InvoiceParts
  class Factory
    def for_booking(invoice, invoice_parts = invoice.invoice_parts)
      [from_deposit(invoice)] +
        invoice.booking.usages.where.not(id: invoice_parts.map(&:usage_id)).map { |usage| from_usage(invoice, usage) }
    end

    def label_2(usage)
      return unless usage.used_units

      [
        usage.tarif.unit &&
          format('%<used_units>d × %<unit>s', used_units: usage.used_units, unit: usage.tarif.unit),
        usage.tarif.price_per_unit &&
          format(' a CHF %0.2f', usage.tarif.price_per_unit)
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
        label: I18n.t(:'activerecord.enums.invoice.invoice_types.deposit'),
        amount: - deposits.sum(&:amount_paid)
      )
    end
  end
end
