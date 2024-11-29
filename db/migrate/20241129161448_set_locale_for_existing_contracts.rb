class SetLocaleForExistingContracts < ActiveRecord::Migration[8.0]
  def up
    Booking.where(concluded: false).find_each do |booking|
      booking.contract&.update(locale: booking.locale)
    end
  end
end
