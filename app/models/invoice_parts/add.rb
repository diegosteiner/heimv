# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_parts
#
#  id              :integer          not null, primary key
#  invoice_id      :integer
#  usage_id        :integer
#  type            :string
#  amount          :decimal(, )
#  label           :string
#  breakdown       :string
#  ordinal         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vat_category_id :integer
#
# Indexes
#
#  index_invoice_parts_on_invoice_id       (invoice_id)
#  index_invoice_parts_on_usage_id         (usage_id)
#  index_invoice_parts_on_vat_category_id  (vat_category_id)
#

module InvoiceParts
  class Add < InvoicePart
    InvoicePart.register_subtype self

    def calculated_amount
      amount
    end

    def journal_entries # rubocop:disable Metrics/AbcSize
      [
        Accounting::JournalEntry.new(
          account: tarif&.accounting_account_nr, date: invoice.issued_at, amount: amount.abs, amount_type: :brutto,
          side: :haben, tax_code: vat_category&.accounting_vat_code, reference: invoice.human_ref, source: self,
          currency: organisation.currency, booking:, cost_center: tarif&.accounting_profit_center_nr,
          text: [invoice.class.model_name.human, invoice.human_ref, label].join(' ')
        )
      ]
    end
  end
end
