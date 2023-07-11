class CreateBookingQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :booking_questions do |t|
      t.references :organisation, null: false, foreign_key: true
      t.datetime :discarded_at
      t.jsonb :label_i18n
      t.jsonb :description_i18n
      t.string :type
      t.integer :ordinal
      t.string :key
      t.boolean :required, default: false
      t.jsonb :options

      t.timestamps
    end
    add_index :booking_questions, :discarded_at
    add_index :booking_questions, :type

    add_column :bookings, :booking_questions, :jsonb
  end
end
