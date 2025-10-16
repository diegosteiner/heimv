# frozen_string_literal: true

class AddRecordIdsToDataDigests < ActiveRecord::Migration[8.0]
  def change
    add_column :data_digests, :record_ids, :jsonb, null: true
  end
end
