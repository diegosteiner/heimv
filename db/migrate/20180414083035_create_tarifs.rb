class CreateTarifs < ActiveRecord::Migration[5.2]
  def change
    create_table :tarifs do |t|
      t.string :type
      t.string :label
      t.boolean :appliable
      t.references :booking, foreign_key: true, type: :uuid
      t.string :unit
      t.decimal :price_per_unit

      t.timestamps
    end
  end
end
