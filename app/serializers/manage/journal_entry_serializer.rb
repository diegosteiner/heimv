# frozen_string_literal: true

module Manage
  class JournalEntrySerializer < ApplicationSerializer
    fields :id, :account_nr, :date, :text, :amount, :side, :ordinal, :source_document_ref, :currency,
           :soll_amount, :haben_amount, :soll_account, :haben_account, :book_type
  end
end
