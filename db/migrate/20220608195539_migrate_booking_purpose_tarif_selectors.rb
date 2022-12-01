class MigrateBookingPurposeBookingConditions < ActiveRecord::Migration[7.0]
  def change
    BookingCondition.where(type: 'BookingConditions::BookingPurpose').update_all(type: 'BookingConditions::BookingCategory')
  end
end
