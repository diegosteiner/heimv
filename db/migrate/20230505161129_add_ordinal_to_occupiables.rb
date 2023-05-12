class AddOrdinalToOccupiables < ActiveRecord::Migration[7.0]
  def change
    add_column :occupiables, :ordinal, :integer, null: true
  end
end
