class AddTenantVisibleToTarifs < ActiveRecord::Migration[6.1]
  def change
    add_column :tarifs, :tenant_visible, :boolean, default: true
  end
end
