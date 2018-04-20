class CreateBookingTransitions < ActiveRecord::Migration[5.1]
  def change
    create_table :booking_transitions do |t|
      t.string :to_state, null: false
      t.integer :sort_key, null: false
      t.belongs_to :booking, null: false, type: :uuid
      t.boolean :most_recent, null: false
      t.timestamps null: false

      if t.respond_to?(:json)
        t.json :metadata, default: {}
        t.json :booking_data, default: {}
      else
        t.string :metadata, default: '{}'
        t.string :booking_data, default: '{}'
      end
    end

    # Foreign keys are optional, but highly recommended
    add_foreign_key :booking_transitions, :bookings

    add_index(:booking_transitions,
              %i[booking_id sort_key],
              unique: true,
              name: 'index_booking_transitions_parent_sort')
    add_index(:booking_transitions,
              %i[booking_id most_recent],
              unique: true,
              where: 'most_recent',
              name: 'index_booking_transitions_parent_most_recent')
  end
end
