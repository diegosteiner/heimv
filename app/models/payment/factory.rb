class Payment
  class Factory
    def from_camt_file(file)
      camt = CamtParser::String.parse file.read
      # puts camt.group_header.creation_date_time
      camt.notifications.map do |notification|
        # puts notification.account.iban
        notification.entries.map do |entry|
          next unless entry.booked? && entry.credit? && entry.currency == 'CHF'

          # invoice = Invoice.where(ref: entry.???)

          # See https://github.com/Barzahlen/camt_parser/blob/master/lib/camt_parser/general/entry.rb
          Payment.new(paid_at: entry.value_date, amount: entry.amount, remarks: entry.description)
        end
      end.flatten.compact
    end
  end
end
