class RenameTransientToPinOnTarifs < ActiveRecord::Migration[7.0]
  def change
    change_column_default :tarifs, :transient, from: false, to: true
    rename_column :tarifs, :transient, :pin

    reversible do |direction|
      Tarif.find_each { |tarif| tarif.update_columns(pin: !tarif.pin) }
    end
  end
end
