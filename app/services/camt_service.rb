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
    return unless entry.credit? && entry.currency.upcase == @organisation.currency.upcase

    entry.transactions.map do |transaction|
      payment_from_transaction(transaction, entry)
    end
  end

  def payment_from_transaction(transaction, entry)
    ref = transaction.creditor_reference
    invoice = find_invoice_by_ref(ref)
    remarks = [transaction.name, entry.description].compact_blank.join("\n\n")
    applies = invoice.present?

    Payment.new(
      invoice:, booking: invoice&.booking, applies:, ref:, confirm: applies,
      paid_at: entry.value_date, amount: transaction.amount, data: transaction_to_h(transaction),
      camt_instr_id: transaction.reference, remarks:, paid_by: transaction.name
    )
  end

  def find_invoice_by_ref(ref)
    # ensures backwards compatibility: the checksum used to be stored in db, but is not anymore.
    normalized_ref_regex = "^0{0,25}#{self.class.normalize_ref(ref)}\\d?$"
    @organisation.invoices.kept.where(Invoice.arel_table[:payment_ref].matches_regexp(normalized_ref_regex)).first
  end

  def self.normalize_ref(ref)
    if ref.start_with?('RF')
      ref.delete(' ').gsub(/\ARF\d\d0*/, '')
    else
      ref.delete(' ').gsub(/\d\z/, '').gsub(/\A0*/, '')
    end
  end

  def transaction_to_h(transaction)
    fields = %i[amount amount_in_cents currency name iban bic debit sign
                remittance_information swift_code reference bank_reference end_to_end_reference mandate_reference
                creditor_reference transaction_id creditor_identifier payment_information additional_information]
    fields.index_with { |field| transaction.try(field) }
  end
end
