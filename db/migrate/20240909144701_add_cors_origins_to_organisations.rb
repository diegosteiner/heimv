class AddCorsOriginsToOrganisations < ActiveRecord::Migration[7.2]
  def change
    add_column :organisations, :cors_origins, :text
  end
end
