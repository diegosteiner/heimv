class CreateTarifTarifSelectors < ActiveRecord::Migration[5.2]
  def change
    create_table :tarif_tarif_selectors do |t|
      t.references :tarif, foreign_key: true
      t.references :tarif_selector, foreign_key: true
      t.boolean :veto, default: true
      t.string :distinction
      # t.jsonb :params

      t.timestamps
    end
  end
end
