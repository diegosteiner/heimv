class AddLocaleToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :locale, :string
    add_index :bookings, :locale
  end
end
