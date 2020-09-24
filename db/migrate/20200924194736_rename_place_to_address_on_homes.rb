class RenamePlaceToAddressOnHomes < ActiveRecord::Migration[6.0]
  def up
    rename_column :homes, :place, :address
    change_column :homes, :address, :text
  end

  def down
    change_column :homes, :address, :string
    rename_column :homes, :address, :place
  end
end
