class AddDiscardToBookingCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :booking_categories, :discarded_at, :datetime
    add_index :booking_categories, :discarded_at
  end
end
