class AllowNullEmailsOnTenants < ActiveRecord::Migration[6.1]
  def change
    change_column_null :tenants, :email, true
  end
end
