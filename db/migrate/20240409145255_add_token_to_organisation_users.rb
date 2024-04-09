class AddTokenToOrganisationUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :organisation_users, :token, :string, null: true
  end
end
