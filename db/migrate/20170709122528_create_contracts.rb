class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :contracts do |t|
      t.belongs_to :booking, foreign_key: true, type: :uuid
      t.datetime :sent_at
      t.datetime :signed_at
      t.text :text
      t.datetime :valid_from
      t.datetime :valid_until

      t.timestamps
    end
  end
end
