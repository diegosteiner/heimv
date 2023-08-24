class AddModeToBookingQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_questions, :mode, :integer, default: 0, null: false
  end
end
