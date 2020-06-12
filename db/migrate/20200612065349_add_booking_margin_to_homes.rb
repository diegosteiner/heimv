class AddBookingMarginToHomes < ActiveRecord::Migration[6.0]
  def change
    add_column :homes, :booking_margin, :integer, default: 0
  end
end
