class InvoicePartBuilder
  def for_booking(booking, invoice, invoice_parts = invoice.invoice_parts)
    booking.usages.where.not(id: invoice_parts.map(&:usage_id)).map do |usage|
      InvoiceParts::Add.new(
        apply: invoice.invoice_type == usage.tarif.invoice_type,
        usage: usage,
        text: usage.tarif.label,
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
