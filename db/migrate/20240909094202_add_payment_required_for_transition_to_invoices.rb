class AddPaymentRequiredForTransitionToInvoices < ActiveRecord::Migration[7.2]
  def change
    add_column :invoices, :payment_required, :boolean, default: true
  end
end
