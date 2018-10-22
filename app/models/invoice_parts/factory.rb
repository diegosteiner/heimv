module InvoiceParts
  class Factory
    def for_booking(booking, invoice, invoice_parts = invoice.invoice_parts)
      booking.usages.where.not(id: invoice_parts.map(&:usage_id)).map do |usage|
        InvoiceParts::Add.new(
          apply: invoice.invoice_type == usage.tarif.invoice_type,
          usage: usage,
          label: usage.tarif.label,
          label_2: label_2(usage),
          amount: usage.price
        )
      end
    end

    def label_2(usage)
      return unless usage.used_units

      [
        usage.tarif.unit &&
          format('%<used_units>d %<unit>s', used_units: usage.used_units, unit: usage.tarif.unit),
        usage.tarif.price_per_unit &&
          format(' a CHF %0.2f', usage.tarif.price_per_unit)
      ].join
    end

    def from_deposit(booking, deposits = booking.invoices.deposit)
      InvoiceParts::Add.new(
        apply: true,
        text: I18n.t(:deposit),
        amount: deposits.sum(&:amount_paid)
      )
    end
  end
end
