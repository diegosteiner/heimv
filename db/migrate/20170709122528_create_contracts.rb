class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :contracts do |t|
      t.belongs_to :booking, foreign_key: true, type: :uuid
      t.date :sent_at
      t.date :signed_at
      t.text :text
      t.datetime :valid_from, null: true, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :valid_until, null: true

      t.timestamps
    end
  end
end
