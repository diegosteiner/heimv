class RenameBookingPurposeToBookingCategory < ActiveRecord::Migration[7.0]
  def change
    rename_column :bookings, :purpose_id, :booking_category_id
    rename_table :booking_purposes, :booking_categories
  end
end
