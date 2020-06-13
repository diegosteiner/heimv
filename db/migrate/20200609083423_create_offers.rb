class CreateOffers < ActiveRecord::Migration[6.0]
  def change
    create_table :offers do |t|
      t.belongs_to :booking, foreign_key: true, type: :uuid
      t.text :text
      t.datetime :valid_from, null: true, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :valid_until, null: true

      t.timestamps
    end
  end
end
