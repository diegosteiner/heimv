class AddMailFromToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :mail_from, :string, null: true
  end
end
