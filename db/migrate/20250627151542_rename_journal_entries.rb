# frozen_string_literal: true

class RenameJournalEntries < ActiveRecord::Migration[8.0]
  def change
    rename_table :journal_entries, :journal_entry_batches
    change_table :journal_entry_batches, bulk: true do |t|
      t.jsonb :entries
      t.string :type # , index: true
    end

    reversible do |direction|
      direction.up do
        map_triggers
        map_fragments
      end
    end
  end

  protected

  def map_triggers
    trigger_map = { 11 => 'JournalEntryBatches::Invoice', 12 => 'JournalEntryBatches::Invoice',
                    13 => 'JournalEntryBatches::Invoice', 21 => 'JournalEntryBatches::Payment',
                    22 => 'JournalEntryBatches::Payment', 23 => 'JournalEntryBatches::Payment' }
    trigger_map.each { |trigger, type| JournalEntryBatch.where(trigger:).update_all(type:) } # rubocop:disable Rails/SkipsModelValidations
  end

  def map_fragments
    JournalEntryBatch.find_each do |jeb|
      fragments = jeb.fragments.dup
      drop_fragment = fragments.shift
      entries = fragments.filter_map do |fragment|
        accounts = if drop_fragment['side'] == 'soll'
                     { soll_account: drop_fragment['account_nr'], haben_account: fragment['account_nr'] }
                   else
                     { soll_account: fragment['account_nr'], haben_account: drop_fragment['account_nr'] }
                   end
        fragment.slice(*%w[text amount book_type invoice_part_id vat_category_id]).merge(accounts)
      end
      jeb.update!(entries:)
    end
  end
end
