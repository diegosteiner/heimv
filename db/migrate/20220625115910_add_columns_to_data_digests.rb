class AddColumnsToDataDigests < ActiveRecord::Migration[7.0]
  def change
    add_column :data_digests, :columns, :jsonb, null: true
  end
end
