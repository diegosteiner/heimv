class AddInstrIdToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :camt_instr_id, :string, null: true
  end
end
