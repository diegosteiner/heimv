class RenameMinimumPriceToMinimumUsageOnTarifs < ActiveRecord::Migration[7.0]
  def change
    rename_column :tarifs, :minimum_price_per_night, :minimum_usage_per_night
    rename_column :tarifs, :minimum_price_total, :minimum_usage_total
  end
end
