class AddUniqueIndexToTenantEmail < ActiveRecord::Migration[6.1]
  def change
    add_index :tenants, %i[email organisation_id], unique: true
  end
end
