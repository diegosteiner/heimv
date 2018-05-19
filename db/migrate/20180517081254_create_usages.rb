class CreateUsages < ActiveRecord::Migration[5.2]
  def change
    create_table :usages do |t|
      t.references :tarif, foreign_key: true
      t.decimal :used_units
      t.text :remarks
      t.references :booking, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
