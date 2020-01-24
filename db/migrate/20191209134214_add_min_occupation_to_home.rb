class AddMinOccupationToHome < ActiveRecord::Migration[6.0]
  def change
    add_column :homes, :min_occupation, :integer, null: true
  end
end
