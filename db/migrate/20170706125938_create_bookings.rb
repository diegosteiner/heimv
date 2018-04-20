class CreateBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :bookings, id: :uuid do |t|
      t.references :home, foreign_key: true, null: false
      t.string :state, index: true, null: false, default: 'initial'
      t.string :organisation, null: true
      t.string :email, null: true
      t.integer :customer_id, foreign_key: true
      t.json :strategy_data
      t.boolean :committed_request, null: true
      t.text :cancellation_reason, null: true
      t.datetime :request_deadline, null: true
      t.integer :approximate_headcount, null: true
      t.text :remarks, null: true
      t.text :invoice_address, null: true
      t.string :event_kind, null: true

      t.timestamps
    end
  end
end
