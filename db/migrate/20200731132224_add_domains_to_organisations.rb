class AddDomainsToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :domain, :string, index: true, null: true
    add_column :organisations, :location, :string, null: true
    add_column :organisations, :messages_enabled, :boolean, default: true
    add_column :organisations, :smtp_url, :string, null: true
  end
end
