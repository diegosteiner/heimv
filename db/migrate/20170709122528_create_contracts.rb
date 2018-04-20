class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :contracts do |t|
      t.references :booking, foreign_key: true, type: :uuid
      t.datetime :sent_at
      t.datetime :signed_at
      t.string :title
      t.text :text
      t.datetime :valid_from
      t.datetime :valid_until

      t.timestamps
    end
  end
end
