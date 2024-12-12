# frozen_string_literal: true

module Manage
  class JournalEntrySerializer < ApplicationSerializer
    fields :id, :account_nr, :date, :text, :amount, :side, :cost_center, :ordinal, :source_document_ref, :currency,
           :soll_amount, :haben_amount, :soll_account, :haben_account

    field :source do |journal_entry|
      {
        type: journal_entry.source&.class&.sti_name,
        id: journal_entry.source&.id
      }
    end

    field :tax_code do |journal_entry|
      journal_entry.vat_category&.accounting_vat_code
    end
  end
end
