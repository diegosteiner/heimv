class InvoicePartBuilder
  def for_booking(booking)
    booking.usages.map { |usage| from_usage(usage) }
  end

  def from_usage(usage)
      InvoicePart.new(
        apply: true,
        usage: usage,
        text: usage.tarif.label,
        amount: usage.price
      )
  end
end
