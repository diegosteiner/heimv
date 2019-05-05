class Payment
  class Factory
    def from_camt_file(file)
      camt = CamtParser::String.parse file.read
      camt.notifications.map do |notification|
        notification.entries.map { |entry| from_camt_entry(entry) }
      end.flatten.compact
    end
  end

  def from_camt_entry(entry)
    return unless entry.booked? && entry.credit? && entry.currency == 'CHF'

    raise 'x'

    # invoice = Invoice.where(ref: entry.???)

    # See https://github.com/Barzahlen/camt_parser/blob/master/lib/camt_parser/general/entry.rb
    Payment.new(paid_at: entry.value_date, amount: entry.amount, remarks: entry.description)
  end
end
