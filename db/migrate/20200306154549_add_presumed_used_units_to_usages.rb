class AddPresumedUsedUnitsToUsages < ActiveRecord::Migration[6.0]
  def change
    add_column :usages, :presumed_used_units, :decimal, null: true
  end
end
