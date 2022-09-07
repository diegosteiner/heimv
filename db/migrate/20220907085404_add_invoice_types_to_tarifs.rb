class AddInvoiceTypesToTarifs < ActiveRecord::Migration[7.0]
  def change
    add_column :tarifs, :accountancy_account, :string, null: true
    add_column :tarifs, :invoice_types, :integer, null: false, default: 0

    reversible do |direction|
      direction.up do 
        Tarif.find_each do |tarif|
          invoice_types = Tarif::INVOICE_TYPES.filter { |key, value| value.to_s == tarif.invoice_type }.keys
          tarif.update(invoice_types: invoice_types) if invoice_types.present?
        end
      end
    end

    remove_column :tarifs, :invoice_type, :string, null: true
  end
end
