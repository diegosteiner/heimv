class CreateBookingTransitions < ActiveRecord::Migration[5.1]
  def change
    create_table :booking_transitions do |t|
      t.string :to_state, null: false
      t.json :metadata, default: {}
      t.integer :sort_key, null: false
      t.integer :booking_id, null: false
      t.boolean :most_recent, null: false
      t.timestamps null: false
    end

    # Foreign keys are optional, but highly recommended
    add_foreign_key :booking_transitions, :bookings

    add_index(:booking_transitions,
              [:booking_id, :sort_key],
              unique: true,
              name: "index_booking_transitions_parent_sort")
    add_index(:booking_transitions,
              [:booking_id, :most_recent],
              unique: true,
              where: 'most_recent',
              name: "index_booking_transitions_parent_most_recent")
  end
end
