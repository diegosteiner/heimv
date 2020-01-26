class AddPaymentDeadlineToOrganisation < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :payment_deadline, :integer, default: 30, null: false
  end
end
