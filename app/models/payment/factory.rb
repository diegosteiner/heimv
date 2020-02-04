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
      ref = transaction.creditor_reference
      invoice = Invoice.find_by(ref: ref)
      Payment.new(
        invoice: invoice, booking: invoice&.booking, applies: invoice.present?, ref: ref,
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

    def from_import(payments_params)
      payments = payments_params.values.map do |payment_params|
        Payment.new(payment_params)
      end.compact

      Payment.transaction do
        raise ActiveRecord::Rollback unless payments.select(&:applies).all?(&:save)
      end

      payments
    end
  end
end
