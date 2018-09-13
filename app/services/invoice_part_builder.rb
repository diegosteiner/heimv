class InvoicePartBuilder
  def for_booking(booking, invoice, invoice_parts = invoice.invoice_parts)
    booking.usages.where.not(id: invoice_parts.map(&:usage_id)).map do |usage|
      InvoiceParts::Add.new(
        apply: invoice.invoice_type == usage.tarif.invoice_type,
        usage: usage,
        label: usage.tarif.label,
        label_2: [format("%d %s", usage.used_units usage.tarif.unit), usage.used_units && usage.tarif.price_per_unit && format(" a CHF %0.2f", usage.tarif.price_per_unit)].join,
        amount: usage.price
      )
    end
  end

  def from_deposit(booking, deposits = booking.invoices.deposit)
    InvoiceParts::Add.new(
      apply: true,
      text: I18n.t(:deposit),
      amount: deposits.sum(&:amount_payed)
    )
  end
end
