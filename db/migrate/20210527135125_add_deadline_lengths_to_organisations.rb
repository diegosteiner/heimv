class AddDeadlineLengthsToOrganisations < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :settings, :jsonb, default: {}
  end
end
