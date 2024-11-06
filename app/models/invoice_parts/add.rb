# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_parts
#
#  id         :integer          not null, primary key
#  invoice_id :integer
#  usage_id   :integer
#  type       :string
#  amount     :decimal(, )
#  label      :string
#  breakdown  :string
#  ordinal    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vat        :decimal(, )
#
# Indexes
#
#  index_invoice_parts_on_invoice_id  (invoice_id)
#  index_invoice_parts_on_usage_id    (usage_id)
#

module InvoiceParts
  class Add < InvoicePart
    InvoicePart.register_subtype self

    def calculated_amount
      amount
    end

    def journal_entry_items
      [
        Accounting::JournalEntryItem.new(account: usage&.tarif&.accounting_account_nr, date: invoice.sent_at,
                                         amount: (amount / ((100 + (vat || 0))) * 100), amount_type: :netto,
                                         side: -1, tax_code: vat.to_s, text: invoice.ref, source: :invoice_part,
                                         invoice_id: invoice.id)
      ]
    end
  end
end
