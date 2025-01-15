# frozen_string_literal: true

module Manage
  class JournalEntryFragmentSerializer < ApplicationSerializer
    fields :account_nr, :text, :amount, :side, :soll_amount, :haben_amount, :soll_account, :haben_account, :book_type,
           :invoice_part_id

    association :journal_entry, blueprint: Manage::JournalEntrySerializer
    association :vat_category, blueprint: Public::VatCategorySerializer
  end
end
