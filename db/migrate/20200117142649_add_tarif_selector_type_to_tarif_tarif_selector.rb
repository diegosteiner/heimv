class AddTarifSelectorTypeToTarifTarifSelector < ActiveRecord::Migration[6.0]
  def up
    add_column :tarif_tarif_selectors, :tarif_selector_type, :string, index: true, null: true

    TarifTarifSelector.find_each do |tarif_tarif_selector|
      tarif_tarif_selector.update(tarif_selector_type: tarif_tarif_selector.tarif_selector.class.to_s)
    end
  end

  def down
    remove_column :tarif_tarif_selectors, :tarif_selector_type, :string, index: true, null: true
  end
end
