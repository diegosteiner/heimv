class AddPaymentInfoTypeToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :payment_info_type, :string
  end
end
