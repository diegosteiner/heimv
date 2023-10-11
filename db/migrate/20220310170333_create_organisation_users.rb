class CreateOrganisationUsers < ActiveRecord::Migration[7.0]
  ROLE_MAPPING = { 0 => 0, 1 => 0, 2 => 2, 3 => 1}.freeze
  def change
    create_table :organisation_users do |t|
      t.references :organisation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false

      t.timestamps
    end

    add_index :organisation_users, %i[organisation_id user_id], unique: true
    rename_column :users, :organisation_id, :default_organisation_id 
    add_column :users, :role_admin, :boolean, default: false
    change_column_null :users, :default_organisation_id, true
    remove_column :users, :role, :integer, default: 0, null: false
  end
end
