# frozen_string_literal: true

module Manage
  class JournalEntrySerializer < ApplicationSerializer
    fields :amount, :soll_account, :haben_account, :text, :invoice_part_id, :vat_category_id, :vat_amount,
           :cost_center

    field(:journal_entry_batch_id) { it.journal_entry_batch.id }

    association :journal_entry_batch, blueprint: Manage::JournalEntryBatchSerializer
    association :vat_category, blueprint: Public::VatCategorySerializer
  end
end
