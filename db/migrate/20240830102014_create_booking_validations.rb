class CreateBookingValidations < ActiveRecord::Migration[7.2]
  def change
    create_table :booking_validations do |t|
      t.references :organisation, null: false, foreign_key: true
      t.jsonb :error_message_i18n
      t.integer :ordinal

      t.timestamps
    end
  end
end
