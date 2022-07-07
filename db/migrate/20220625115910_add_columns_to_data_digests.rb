class AddColumnsToDataDigests < ActiveRecord::Migration[7.0]
  def change
    add_column :data_digests, :column_config, :jsonb, null: true
  end
end
