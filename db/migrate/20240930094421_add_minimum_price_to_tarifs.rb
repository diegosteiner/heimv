class AddMinimumPriceToTarifs < ActiveRecord::Migration[7.2]
  def change
    add_column :tarifs, :minimum_price_per_night, :decimal, null: true
    add_column :tarifs, :minimum_price_total, :decimal, null: true
  end
end
