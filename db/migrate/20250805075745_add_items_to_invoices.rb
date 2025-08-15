# frozen_string_literal: true

class AddItemsToInvoices < ActiveRecord::Migration[8.0]
  MAP_TYPES = {
    'InvoiceParts::Add' => 'Invoice::Items::Add',
    'InvoiceParts::Title' => 'Invoice::Items::Title',
    'InvoiceParts::Text' => 'Invoice::Items::Text',
    'InvoiceParts::Deposit' => 'Invoice::Items::Deposit',
    'InvoiceParts::Percentage' => 'Invoice::Items::Percentage'
  }.freeze

  def change
    Rails.application.eager_load!

    add_column :invoices, :items, :jsonb
    reversible do |direction|
      direction.up do
        migrate_journal_entries
        migrate_invoice_parts
      end
    end
  end

  def migrate_invoice_parts
    table = Arel::Table.new(:invoice_parts)
    query = table.project(Arel.star).order(table[:ordinal])
    ActiveRecord::Base.connection.exec_query(query.to_sql).to_a.each do |invoice_part|
      invoice_part.symbolize_keys!
      item_hash = invoice_part.slice(*%i[apply accounting_account_nr accounting_cost_center_nr id
                                         amount breakdown label type usage_id vat_category_id ])
      item_hash[:type] = MAP_TYPES[item_hash[:type]]
      invoice = Invoice.find(invoice_part[:invoice_id])
      invoice.items ||= []
      invoice.items << Invoice::Item.one_of.to_type.cast_value(item_hash)
      invoice.save!
    end
  end

  def migrate_journal_entries
    JournalEntryBatch.find_each do |journal_entry_batch|
      entry_hashes = JSON.parse(journal_entry_batch.entries_before_type_cast)
      entry_hashes = Array.wrap(entry_hashes).map do |entry_hash|
        entry_hash.symbolize_keys!
        entry_hash[:invoice_item_id] = entry_hash[:invoice_part_id]
        entry_hash
      end
      journal_entry_batch.update!(entries: JSON.generate(entry_hashes))
    end
  end
end
