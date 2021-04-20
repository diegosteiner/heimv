class AddCountryCodeToTenants < ActiveRecord::Migration[6.1]
  def change
    add_column :tenants, :country_code, :string
  end
end
