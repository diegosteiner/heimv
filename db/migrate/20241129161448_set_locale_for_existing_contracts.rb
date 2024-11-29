class SetLocaleForExistingContracts < ActiveRecord::Migration[8.0]
  def up
    Booking.where(concluded: false).joins(:contracts).includes(:contracts)
           .where.not(contracts: { id: nil }).find_each do |booking|
      booking.contract.skip_generate_pdf = true
      booking.contract.update_columns(locale: booking.locale)
    end
  end
end
