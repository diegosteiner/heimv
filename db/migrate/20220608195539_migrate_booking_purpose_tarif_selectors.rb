class MigrateBookingPurposeTarifSelectors < ActiveRecord::Migration[7.0]
  def change
    return unless defined?(TarifSelector)
    TarifSelector.where(type: 'TarifSelectors::BookingPurpose').update_all(type: 'TarifSelectors::BookingCategory')
  end
end
