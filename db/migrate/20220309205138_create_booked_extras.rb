class CreateBookedExtras < ActiveRecord::Migration[7.0]
  def change
    create_table :booked_extras do |t|
      t.uuid :booking_id, null: false, foreign_key: true
      t.references :bookable_extra, null: false, foreign_key: true

      t.timestamps
    end
  end
end
