class AddSalutationToTenants < ActiveRecord::Migration[7.2]
  def change
    add_column :tenants, :salutation_form, :integer, null: true

    reversible do |direction|
      direction.up do
        Tenant.update_all(salutation_form: 1) # :informal_neutral
      end
    end
  end
end
