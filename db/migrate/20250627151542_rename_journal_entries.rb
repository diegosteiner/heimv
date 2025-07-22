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
        migrate_journal_entry_batches
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

  def migrate_journal_entry_batches
    JournalEntryBatch.find_each { it.update!(entries: migrate_fragments(it.fragments.dup)) }
  end

  def migrate_fragments(fragments) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    missing_side = (%w[soll haben] - fragments.pluck('side').uniq).first
    drop_fragment = missing_side ? { 'side' => missing_side, 'account_nr' => '0' } : fragments.shift
    last_main_fragment = nil

    fragments.filter_map do |fragment|
      case fragment['book_type']
      when 'main'
        last_main_fragment = fragment
      when 'vat'
        last_main_fragment['amount'] = (last_main_fragment['amount'].to_f + fragment['amount'].to_f).round(4)
        last_main_fragment['vat_amount'] ||= fragment['amount'].to_f.round(4)
        last_main_fragment['vat_category_id'] ||= fragment['vat_category_id']
        next
      when 'cost'
        last_main_fragment['cost_center'] ||= fragment['account_nr']
        next
      else
        raise ArgumentError
      end

      accounts = if drop_fragment['side'] == 'soll'
                   { soll_account: drop_fragment['account_nr'], haben_account: fragment['account_nr'] }
                 else
                   { soll_account: fragment['account_nr'], haben_account: drop_fragment['account_nr'] }
                 end
      fragment.slice!(*%w[text amount invoice_part_id vat_category_id vat_amount])
      fragment.merge!(accounts)
      fragment
    end
  end
end
