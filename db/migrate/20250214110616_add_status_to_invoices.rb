class AddStatusToInvoices < ActiveRecord::Migration[8.0]
  def change
    add_column :invoices, :status, :integer, null: true

    reversible do |direction|
      direction.up do
        Invoice.find_each { it.set_status; it.save! }
        Invoice.where(status: nil).update_all(status: :draft)
      end
    end

    change_column_default :invoices, :status, 0
    change_column_null :invoices, :status, false
  end
end
