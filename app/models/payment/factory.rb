# frozen_string_literal: true

class Payment
  class Factory
    def initialize(organisation)
      @organisation = organisation
    end

    def from_camt_file(file)
      camt = CamtParser::String.parse file.read
      camt.notifications.map do |notification|
        notification.entries.flat_map { |entry| from_camt_entry(entry) }
      end.flatten.compact
    end

    def from_camt_entry(entry)
      return unless entry.booked? && entry.credit? && entry.currency.upcase == @organisation.currency.upcase

      entry.transactions.map do |transaction|
        from_camt_transaction(transaction, entry)
      end
    end

    def find_invoice_by_ref(ref)
      @organisation.invoice_ref_strategy.find_invoice_by_ref(ref, scope: @organisation.invoices.kept)
    end

    def from_camt_transaction(transaction, entry)
      ref = transaction.creditor_reference
      invoice = find_invoice_by_ref(ref)
      remarks = [transaction.name, entry.description].compact_blank.join("\n\n")

      Payment.new(
        invoice:, booking: invoice&.booking, applies: invoice.present?, ref:,
        paid_at: entry.value_date, amount: transaction.amount, data: camt_transaction_to_h(transaction),
        camt_instr_id: transaction.reference, remarks:
      )
    end

    def camt_transaction_to_h(transaction)
      fields = %i[amount amount_in_cents currency name iban bic debit sign
                  remittance_information swift_code reference bank_reference end_to_end_reference mandate_reference
                  creditor_reference transaction_id creditor_identifier payment_information additional_information]
      fields.index_with { |field| transaction.try(field) }
    end

    def from_import(payments_params)
      payments = payments_params.values.filter_map { |payment_params| Payment.new(payment_params) }
      payments = payments.select(&:applies)

      Payment.transaction do
        raise ActiveRecord::Rollback unless payments.all?(&:save)
      end

      payments
    end
  end
end
