class AddLocaleToOrganisation < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :locale, :string, default: I18n.locale
    Organisation.reset_column_information
  end
end
