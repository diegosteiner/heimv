class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :contracts do |t|
      t.references :booking, foreign_key: true
      t.datetime :sent_at
      t.datetime :signed_at
      t.string :title
      t.text :text

      t.timestamps
    end
  end
end
