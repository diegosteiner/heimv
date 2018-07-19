class InvoicePartBuilder
  def for_booking(booking, invoice_parts = [])
    booking.usages.where.not(id: invoice_parts.map(&:usage_id)).map do |usage|
      from_usage(usage, invoice_parts.none?)
    end
  end

  def from_usage(usage, apply = true)
    InvoiceParts::Add.new(
      apply: apply,
      usage: usage,
      text: usage.tarif.label,
      amount: usage.price
    )
  end
end
