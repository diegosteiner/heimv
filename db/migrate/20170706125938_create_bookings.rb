class CreateBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :bookings do |t|
      t.references :home, foreign_key: true, null: false
      t.string :state, index: true, null: false, default: 'initial'
      t.integer :customer_id, foreign_key: true

      t.timestamps
    end
  end
end
