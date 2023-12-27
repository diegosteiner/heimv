# frozen_string_literal: true

class CamtService
  def initialize(organisation)
    @organisation = organisation
  end

  def payments_from_file(file) # rubocop:disable Metrics/CyclomaticComplexity
    camt = CamtParser::String.parse file.read
    entries = case camt
              when CamtParser::Format053::Base
                camt.statements.flat_map(&:entries)
              when CamtParser::Format054::Base
                camt.notifications.flat_map(&:entries)
              end

    entries&.flat_map { |entry| payments_from_entry(entry) }&.compact
  end

  def payments_from_entry(entry)
    return unless entry.booked? && entry.credit? && entry.currency.upcase == @organisation.currency.upcase

    entry.transactions.map do |transaction|
      payment_from_transaction(transaction, entry)
    end
  end

  def payment_from_transaction(transaction, entry)
    ref = transaction.creditor_reference
    invoice = find_invoice_by_ref(ref)
    remarks = [transaction.name, entry.description].compact_blank.join("\n\n")

    Payment.new(
      invoice:, booking: invoice&.booking, applies: invoice.present?, ref:,
      paid_at: entry.value_date, amount: transaction.amount, data: transaction_to_h(transaction),
      camt_instr_id: transaction.reference, remarks:
    )
  end

  def find_invoice_by_ref(ref)
    @organisation.invoice_ref_strategy.find_invoice_by_ref(ref, scope: @organisation.invoices.kept)
  end

  def transaction_to_h(transaction)
    fields = %i[amount amount_in_cents currency name iban bic debit sign
                remittance_information swift_code reference bank_reference end_to_end_reference mandate_reference
                creditor_reference transaction_id creditor_identifier payment_information additional_information]
    fields.index_with { |field| transaction.try(field) }
  end
end
