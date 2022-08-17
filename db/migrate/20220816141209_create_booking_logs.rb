class CreateBookingLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :booking_logs do |t|
      t.uuid :booking_id, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.jsonb :data

      t.timestamps
    end
  end
end
