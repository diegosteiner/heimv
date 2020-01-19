class RenameTarifTarifSelectorToTarifSelector < ActiveRecord::Migration[6.0]
  def change
    remove_column :tarif_tarif_selectors, :tarif_selector_id, :bigint
    drop_table :tarif_selectors do |t|
      t.bigint "home_id"
      t.string "type"
      t.integer "position"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    rename_table :tarif_tarif_selectors, :tarif_selectors
    rename_column :tarif_selectors, :tarif_selector_type, :type
  end
end
