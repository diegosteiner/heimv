class AddSettingsToHomes < ActiveRecord::Migration[7.0]
  def change
    add_column :homes, :settings, :jsonb

    remove_column :homes, :min_occupation, :integer
    remove_column :homes, :booking_margin, :integer
  end
end
