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
        from_camt_transaction(transaction, entry)
      end
    end

    def from_camt_transaction(transaction, entry)
      invoice = Invoice.find_by(ref: transaction.creditor_reference)
      Payment.new(
        invoice: invoice, booking: invoice&.booking, applies: invoice.present?,
        paid_at: entry.value_date, amount: transaction.amount, data: camt_transaction_to_h(transaction),
        remarks: [transaction.name, entry.description].reject(&:blank?).join("\n\n")
      )
    end

    def camt_transaction_to_h(transaction)
      fields = %i[amount amount_in_cents currency name iban bic debit sign
                  remittance_information swift_code reference bank_reference end_to_end_reference mandate_reference
                  creditor_reference transaction_id creditor_identifier payment_information additional_information]
      fields.map { |field| [field, transaction.try(field)] }.to_h
    end
  end
end
