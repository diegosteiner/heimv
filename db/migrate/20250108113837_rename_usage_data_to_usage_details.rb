# frozen_string_literal: true

class RenameUsageDataToUsageDetails < ActiveRecord::Migration[8.0]
  def change
    rename_column :usages, :data, :details
  end
end
