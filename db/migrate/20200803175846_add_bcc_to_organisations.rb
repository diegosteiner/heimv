class AddBccToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :bcc, :string, null: true
  end
end
