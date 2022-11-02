class AddCrunchingTimestampsToDataDigests < ActiveRecord::Migration[7.0]
  def change
    add_column :data_digests, :crunching_started_at, :datetime, null: true
    add_column :data_digests, :crunching_finished_at, :datetime, null: true
  end
end
