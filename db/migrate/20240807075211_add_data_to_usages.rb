class AddDataToUsages < ActiveRecord::Migration[7.1]
  def change
    add_column :usages, :data, :jsonb, null: true
  end
end
