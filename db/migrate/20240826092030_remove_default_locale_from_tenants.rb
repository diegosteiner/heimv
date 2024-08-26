class RemoveDefaultLocaleFromTenants < ActiveRecord::Migration[7.1]
  def change
    change_column_default :organisations, :locale, from: :de, to: nil
    change_column_default :tenants, :locale, from: :de, to: nil
    change_column_default :operators, :locale, from: :de, to: nil
  end
end
