class AddNicknameToTenants < ActiveRecord::Migration[6.1]
  def change
    add_column :tenants, :nickname, :string
  end
end
