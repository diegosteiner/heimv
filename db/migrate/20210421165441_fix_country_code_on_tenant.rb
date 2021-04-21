class FixCountryCodeOnTenant < ActiveRecord::Migration[6.1]
  def change
    remove_column :tenants, :country, :string

    reversible do |direction|
      direction.up do 
        Tenant.where(country_code: nil).update_all(country_code: 'CH')
      end
    end
  end
end
