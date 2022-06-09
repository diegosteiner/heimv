class MigrateBookingPurposeTarifSelectors < ActiveRecord::Migration[7.0]
  def change
    TarifSelector.where(type: 'TarifSelectors::BookingPurpose').update_all(type: 'TarifSelectors::BookingCategory')
  end
end
