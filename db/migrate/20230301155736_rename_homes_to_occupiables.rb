class RenameHomesToOccupiables < ActiveRecord::Migration[7.0]
  def change
    rename_table :homes, :occupiables 
    add_column :occupiables, :type, :string, null: true
    add_column :occupiables, :occupiable, :boolean, default: false
    add_reference :occupiables, :home, null: true
    rename_column :occupiables, :address, :description
    rename_column :occupiables, :requests_allowed, :bookable

    reversible do |direction|
      direction.up do
        Occupiable.update_all(type: Home.to_s, occupiable: true) 
      end
    end

    change_column_null :occupiables, :type, false
    rename_column :occupancies, :home_id, :occupiable_id
  end
end
