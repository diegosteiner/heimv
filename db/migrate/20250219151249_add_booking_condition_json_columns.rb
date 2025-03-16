class AddBookingConditionJsonColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :tarifs, :selecting_conditions, :jsonb, null: true
    add_column :tarifs, :enabling_conditions, :jsonb, null: true
    add_column :booking_validations, :enabling_conditions, :jsonb, null: true
    add_column :booking_validations, :validating_conditions, :jsonb, null: true
    add_column :booking_questions, :validating_conditions, :jsonb, null: true
    add_column :designated_documents, :attaching_conditions, :jsonb, null: true
    add_column :operator_responsibilities, :applying_conditions, :jsonb, null: true
  end
end
