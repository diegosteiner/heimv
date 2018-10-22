class Payment
  class Factory
    def from_camt_file(file)
      camt = CamtParser::File.parse file
      # puts camt.group_header.creation_date_time
      camt.notifications.map do |notification|
          # puts notification.account.iban
          notification.entries.map do |entry|
            entry.currency
            entry.booked?
            entry.credit?
            entry.description

            # See https://github.com/Barzahlen/camt_parser/blob/master/lib/camt_parser/general/entry.rb
            # binding.pry
            Payment.build(paid_at: entry.value_date, amount: entry.amount)
          end
      end.flatten
    end
  end
end
