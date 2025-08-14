# frozen_string_literal: true

class AddItemsToInvoices < ActiveRecord::Migration[8.0]
  def change
    add_column :invoices, :items, :jsonb
    reversible do |direction|
      direction.up do
        migrate_invoice_parts
        migrate_journal_entries
      end
    end
  end

  def migrate_invoice_parts
    table = Arel::Table.new(:invoice_parts)
    query = table.project(Arel.star).order(table[:ordinal])
    ActiveRecord::Base.connection.exec_query(query.to_sql).to_a.each do |invoice_part|
      invoice_part.symbolize_keys!
      invoice = Invoice.find(invoice_part[:invoice_id])
      invoice.items ||= []
      invoice.items << invoice_part.slice(*%i[apply accounting_account_nr accounting_cost_center_nr
                                              amount breakdown label type usage_id vat_category_id
                                              id])
      invoice.reload.save!
    end
  end

  def migrate_journal_entries
    JournalEntryBatch.find_each do |journal_entry_batch|
      entry_hashes = JSON.parse(journal_entry_batch.entries_before_type_cast)
      entry_hashes = Array.wrap(entry_hashes).map do
        it['invoice_item_id'] = it['invoice_part_id']
        it
      end
      journal_entry_batch.entries = JSON.generate(entry_hashes)
      journal_entry_batch.save!
    end
  end
end
