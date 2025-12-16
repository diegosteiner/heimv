# frozen_string_literal: true

class AddRequiringConditionsToBookingQuestions < ActiveRecord::Migration[8.1]
  def change
    change_table :booking_questions do |t|
      t.jsonb :requiring_conditions, null: true
      t.jsonb :default_value, null: true
    end
    migrate_requiring_conditions
    remove_column :booking_questions, :required, :boolean, null: true
  end

  def migrate_requiring_conditions
    table = BookingQuestion.arel_table
    required_condition = { type: BookingConditions::Always.to_s }
    update = Arel::UpdateManager.new
    update.table(table)
    update.where(table[:required].eq(true))
    update.set([[table[:requiring_conditions], Arel::Nodes::Quoted.new([required_condition].to_json)]])
    execute(update.to_sql)
  end
end
