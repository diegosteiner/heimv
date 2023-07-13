class AddVatToTarifs < ActiveRecord::Migration[7.0]
  def change
    add_column :tarifs, :vat, :decimal
  end
end
