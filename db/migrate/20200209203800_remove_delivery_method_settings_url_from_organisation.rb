class RemoveDeliveryMethodSettingsUrlFromOrganisation < ActiveRecord::Migration[6.0]
  def change
    remove_column :organisations, :delivery_method_settings_url, :string, null: true
  end
end
