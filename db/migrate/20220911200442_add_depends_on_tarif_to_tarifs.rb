class AddDependsOnTarifToTarifs < ActiveRecord::Migration[7.0]
  def change
    add_reference :tarifs, :depends_on_tarif, null: true, foreign_key: { to_table: :tarifs }
  end
end
