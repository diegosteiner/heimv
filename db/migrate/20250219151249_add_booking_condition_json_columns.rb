class AddBookingConditionJsonColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :tarifs, :selecting_condition, :jsonb, null: true
    add_column :tarifs, :enabling_condition, :jsonb, null: true
    add_column :booking_validations, :enabling_condition, :jsonb, null: true
    add_column :booking_validations, :validating_condition, :jsonb, null: true
    add_column :booking_questions, :validating_condition, :jsonb, null: true
    add_column :designated_documents, :attaching_condition, :jsonb, null: true
    add_column :operator_responsibilities, :applying_condition, :jsonb, null: true
  end
end
