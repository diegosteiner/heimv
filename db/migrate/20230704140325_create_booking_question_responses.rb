class CreateBookingQuestionResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :booking_question_responses do |t|
      t.uuid :booking_id, null: false, foreign_key: true
      t.references :booking_question, null: false, foreign_key: true
      t.jsonb :value

      t.timestamps
    end
  end
end
