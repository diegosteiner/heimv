class RenameProfitCenterToCostCenterOnTarifs < ActiveRecord::Migration[8.0]
  def change
    rename_column :tarifs, :accounting_profit_center_nr, :accounting_cost_center_nr
  end
end
