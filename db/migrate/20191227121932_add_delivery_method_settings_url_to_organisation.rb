class AddDeliveryMethodSettingsUrlToOrganisation < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :delivery_method_settings_url, :string, null: true
  end
end
