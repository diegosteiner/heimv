class AddSlugToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :slug, :string
    add_index :organisations, :slug
  end
end
