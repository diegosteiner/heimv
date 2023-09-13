class AddBookingQuestionPrefillMultiplierToTarifs < ActiveRecord::Migration[7.0]
  def change
    add_reference :tarifs, :prefill_usage_booking_question, null: true,
                            foreign_key: { to_table: :booking_questions } 

  end
end
