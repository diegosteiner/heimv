class CreateTarifSelectors < ActiveRecord::Migration[5.2]
  def change
    create_table :tarif_selectors do |t|
      t.references :home, foreign_key: true
      t.string :type, index: true
      t.integer :position

      t.timestamps
    end
  end
end
