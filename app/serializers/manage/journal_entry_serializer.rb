# frozen_string_literal: true

module Manage
  class JournalEntrySerializer < ApplicationSerializer
    fields :account_nr, :text, :amount, :side, :soll_amount, :haben_amount, :soll_account, :haben_account, :book_type,
           :invoice_part_id

    association :journal_entry_batch, blueprint: Manage::JournalEntryBatchSerializer
    association :vat_category, blueprint: Public::VatCategorySerializer
  end
end
