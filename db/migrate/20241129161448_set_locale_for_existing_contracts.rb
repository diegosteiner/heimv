class SetLocaleForExistingContracts < ActiveRecord::Migration[8.0]
  def up
    Booking.where(concluded: false).find_each do |booking|
      next if booking.contract.blank?

      booking.contract.skip_generate_pdf = true
      booking.contract.update(locale: booking.locale)
    end
  end
end
