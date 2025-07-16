# frozen_string_literal: true

module Manage
  class JournalEntrySerializer < ApplicationSerializer
    fields :amount, :soll_account, :haben_account, :text, :invoice_part_id, :vat_category_id, :vat_amount,
           :accounting_cost_center

    association :journal_entry_batch, blueprint: Manage::JournalEntryBatchSerializer
    association :vat_category, blueprint: Public::VatCategorySerializer
  end
end
