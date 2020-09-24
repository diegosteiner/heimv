class RenamePlaceToAddressOnHomes < ActiveRecord::Migration[6.0]
  def change
    rename_column :homes, :place, :address
    change_column :homes, :address, :text
  end
end
