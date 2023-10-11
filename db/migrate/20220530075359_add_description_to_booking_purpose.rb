class AddDescriptionToBookingPurpose < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_purposes, :description_i18n, :jsonb, null: true
    add_column :bookings, :purpose_description, :string, null: true
    remove_column :bookings, :purpose_key, :string, null: true
  end
end
