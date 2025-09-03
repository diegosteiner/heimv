# frozen_string_literal: true

class AddItemsToInvoices < ActiveRecord::Migration[8.0]
  MAP_TYPES = {
    'InvoiceParts::Add' => 'Invoice::Items::Add',
    'InvoiceParts::Title' => 'Invoice::Items::Title',
    'InvoiceParts::Text' => 'Invoice::Items::Text',
    'InvoiceParts::Deposit' => 'Invoice::Items::Deposit',
    'InvoiceParts::Percentage' => 'Invoice::Items::Add'
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
    count = 0
    table = Arel::Table.new(:invoice_parts)
    Invoice.find_each do |invoice|
      batch_query = table.project(Arel.star).order(table[:ordinal]).where(table[:invoice_id].eq(invoice.id))
      rows = ActiveRecord::Base.connection.exec_query(batch_query.to_sql)
      rows.each { migrate_invoice_part(it, invoice) }
      invoice.skip_generate_pdf = true
      invoice.skip_journal_entry_batches = true
      invoice.save!
      count += 1
      GC.start if (count % 1000).zero?
    end
  end

  def migrate_invoice_part(invoice_part, invoice)
    invoice_part.symbolize_keys!
    item_hash = invoice_part.slice(*%i[apply accounting_account_nr accounting_cost_center_nr id
                                       amount breakdown label type usage_id vat_category_id ])
    item_hash[:type] = MAP_TYPES[item_hash[:type]]
    invoice.items ||= []
    invoice.items << Invoice::Item.one_of.to_type.cast_value(item_hash)
  end

  def migrate_entry(entry)
    entry.symbolize_keys!
    entry[:invoice_item_id] = entry[:invoice_part_id]
    entry
  end

  def migrate_journal_entries
    count = 0
    JournalEntryBatch.in_batches(of: 100) do |journal_entry_batch_batch|
      journal_entry_batch_batch.pluck(:id, 'entries AS entries_json').each do |id, entries|
        entries = Array.wrap(entries).map { migrate_entry(it) }
        JournalEntryBatch.where(id:).update_all(entries: JSON.generate(entries)) # rubocop:disable Rails/SkipsModelValidations
      end
      count += 1
      GC.start if (count % 1000).zero?
    end
  end
end
