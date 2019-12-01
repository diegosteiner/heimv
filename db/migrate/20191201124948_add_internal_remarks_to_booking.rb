class AddInternalRemarksToBooking < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :internal_remarks, :text, null: true
  end
end
