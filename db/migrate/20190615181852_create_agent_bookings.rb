class CreateAgentBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :agent_bookings, id: :uuid do |t|
      t.references :booking, foreign_key: true, type: :uuid
      t.string :booking_agent_code, foreign_key: true, null: true
      t.string :booking_agent_ref, null: true
      t.boolean :committed_request
      t.boolean :accepted_request
      t.text :remarks, null: true

      t.timestamps
    end
  end
end
