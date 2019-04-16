class CreateBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :bookings, id: :uuid do |t|
      t.references :home, foreign_key: true, null: false
      t.string :state, index: true, null: false, default: "initial"
      t.string :tenant_organisation, null: true
      t.string :email, null: true
      t.integer :tenant_id, foreign_key: true
      t.json :state_data, default: {}
      t.boolean :committed_request, null: true
      t.text :cancellation_reason, null: true
      t.integer :approximate_headcount, null: true
      t.text :remarks, null: true
      t.text :invoice_address, null: true
      t.string :purpose, null: true
      t.string :ref, unique: true, index: true
      t.boolean :editable, default: true
      t.boolean :usages_entered, default: false
      t.boolean :messages_enabled, default: false

      t.timestamps
    end
  end
end
