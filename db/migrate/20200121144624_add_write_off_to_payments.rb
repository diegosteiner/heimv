class AddWriteOffToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :write_off, :boolean, default: false, null: false
  end
end
