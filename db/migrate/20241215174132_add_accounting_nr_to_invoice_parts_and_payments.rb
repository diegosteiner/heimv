class AddAccountingNrToInvoicePartsAndPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :invoice_parts, :accounting_account_nr, :string, null: true
    add_column :invoice_parts, :accounting_cost_center_nr, :string, null: true
    add_column :payments, :accounting_account_nr, :string, null: true
    add_column :payments, :accounting_cost_center_nr, :string, null: true

    reversible do |direction|
      direction.up do
        Tarif.find_each do |tarif|
          next unless tarif.accounting_account_nr.present? || tarif.accounting_cost_center_nr.present?

          InvoicePart.joins(:usage).where(usage: { tarif: tarif })
                     .update_all(accounting_account_nr: tarif.accounting_account_nr.presence,
                                 accounting_cost_center_nr: tarif.accounting_cost_center_nr.presence)
        end
      end
    end
  end
end
