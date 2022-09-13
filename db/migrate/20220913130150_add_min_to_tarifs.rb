class AddMinToTarifs < ActiveRecord::Migration[7.0]
  def change
    add_column :tarifs, :minimum_price_per_night, :decimal, null: true
    add_column :tarifs, :minimum_price_total, :decimal, null: true

    remove_reference :tarifs, :depends_on_tarif, null: true, foreign_key: { to_table: :tarifs }
  end
end
