class Payment
  class Factory
    def from_camt_file(file)
      camt = CamtParser::String.parse file.read
      camt.notifications.map do |notification|
        notification.entries.flat_map { |entry| from_camt_entry(entry) }
      end.flatten.compact
    end

    def from_camt_entry(entry)
      return unless entry.booked? && entry.credit? && entry.currency == 'CHF'

      entry.transactions.map do |transaction|
        invoice = Invoice.find_by(esr_number: transaction.creditor_reference)
        Payment.new(
          invoice: invoice, booking: invoice&.booking, applies: invoice.present?,
          paid_at: entry.value_date, amount: transaction.amount, remarks: entry.description
        )
      end
    end
  end
end
