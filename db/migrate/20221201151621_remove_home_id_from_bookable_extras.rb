class RemoveHomeIdFromBookableExtras < ActiveRecord::Migration[7.0]
  def change
    remove_column :bookable_extras, :home_id
  end
end
