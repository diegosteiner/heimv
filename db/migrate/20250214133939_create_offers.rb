class CreateOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :offers do |t|
      t.references :booking, type: :uuid, null: false, foreign_key: true
      t.datetime :issued_at, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :valid_until, null: true
      t.datetime :sent_at, null: true
      t.text :text
      t.datetime :discarded_at, null: true
      t.string :locale
      t.integer :sequence_number
      t.integer :sequence_year
      t.string :ref

      t.timestamps
    end
  end

  protected

  def migrate_existing_offers
    existing_offers_query = Invoice.arel_table.project(*%[booking_id sequence_year sequence_number text
                                                          invoice_parts].map { Invoice.arel_table[it]})
  end
end
