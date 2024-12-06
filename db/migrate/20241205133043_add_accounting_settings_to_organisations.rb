class AddAccountingSettingsToOrganisations < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :accounting_settings, :jsonb, default: {}
  end
end
