class RemoveOldAttributes < ActiveRecord::Migration[7.0]
  def change
    remove_column :organisations, :payment_deadline, default: 30, null: false
    remove_column :invoices, :print_payment_slip, default: false
    remove_column :tarifs, :booking_id, :uuid, null: true
  end
end
