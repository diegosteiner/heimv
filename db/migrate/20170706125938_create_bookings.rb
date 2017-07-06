class CreateBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :bookings do |t|
      t.references :occupancy, foreign_key: true
      t.references :home, foreign_key: true
      t.string :state, index: true
      t.integer :customer_id, foreign_key: true

      t.timestamps
    end
  end
end
