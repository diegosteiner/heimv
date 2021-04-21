class AddDefaultAllowToTenants < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:tenants, :reservations_allowed, from: false, to: true)
    change_column_default(:tenants, :country_code, from: nil, to: 'CH')

    reversible do |direction|
      direction.up do 
        Tenant.update_all(reservations_allowed: true)
      end
    end
  end
end
