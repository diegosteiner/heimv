class RemoveNullOnLocaleForTenants < ActiveRecord::Migration[7.2]
  def change
    change_column_null :tenants, :locale, true
  end
end
