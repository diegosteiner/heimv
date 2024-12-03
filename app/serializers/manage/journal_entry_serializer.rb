# frozen_string_literal: true

module Manage
  class JournalEntrySerializer < ApplicationSerializer
    fields :id, :account, :date, :tax_code, :text, :amount, :side, :cost_center,
           :index, :amount_type, :reference, :currency, :to_s, :soll_account, :haben_account

    field :booking_id do |journal_entry|
      journal_entry.booking&.id
    end

    field :source do |journal_entry|
      {
        type: journal_entry.source&.class&.sti_name,
        id: journal_entry.source&.id
      }
    end
  end
end
