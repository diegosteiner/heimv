class AddEmailToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :email, :string, null: true
  end
end
