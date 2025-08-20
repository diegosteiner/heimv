# frozen_string_literal: true

class SeperateOffersFromInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :quotes do |t|
      t.references :booking, type: :uuid, foreign_key: true
      t.datetime :issued_at, null: true
      t.datetime :valid_until, null: true
      t.datetime :sent_at, null: true
      t.text :text, null: true
      t.decimal :amount, default: '0.0'
      t.datetime :discarded_at, null: true
      t.string :locale
      t.integer :sequence_number
      t.integer :sequence_year
      t.string :ref, null: true
      t.references :sent_with_notification, null: true, foreign_key: { to_table: :notifications }
      t.jsonb :items
      t.timestamps
    end

    reversible do |direction|
      direction.up do
        migrate_rich_text_templates
        migrate_key_sequences
        migrate_offers
      end
    end
  end

  def migrate_offers
    table = Arel::Table.new(:invoices)
    batch_size = 100
    offset = 0
    loop do
      batch_query = table.project(Arel.star).where(table[:type].eq('Invoices::Offer')).take(batch_size).skip(offset)
      offset += batch_size
      rows = ActiveRecord::Base.connection.exec_query(batch_query.to_sql)
      break if rows.empty?

      rows.each { migrate_offer(it) }
    end
  end

  def migrate_offer(offer_hash)
    offer_hash.symbolize_keys!
    quote = Quote.new(offer_hash.slice(*%i[booking_id text sent_at text amount discarded_at locale
                                           sequence_number sequence_year ref sent_with_notification items]))
    quote.assign_attributes(valid_until: offer_hash[:payable_until])
    quote.save
  end

  def migrate_rich_text_templates
    RichTextTemplate.where(key: 'invoices_offer_text').update_all(key: 'quote_text') # rubocop:disable Rails/SkipsModelValidations
    RichTextTemplate.where(key: 'email_offer_notification').update_all(key: 'email_quote_notification') # rubocop:disable Rails/SkipsModelValidations
  end

  def migrate_key_sequences
    KeySequence.where(key: 'Invoices::Offer').update_all(key: 'Quote') # rubocop:disable Rails/SkipsModelValidations
  end
end
