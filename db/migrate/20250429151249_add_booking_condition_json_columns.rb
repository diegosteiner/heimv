# frozen_string_literal: true

class AddBookingConditionJsonColumns < ActiveRecord::Migration[8.0]
  def change
    change_table :tarifs, bulk: true do |t|
      t.column :selecting_conditions, :jsonb, null: true
      t.column :enabling_conditions, :jsonb, null: true
    end
    change_table :booking_validations, bulk: true do |t|
      t.column :validating_conditions, :jsonb, null: true
      t.column :enabling_conditions, :jsonb, null: true
    end
    add_column :booking_questions, :applying_conditions, :jsonb, null: true
    add_column :designated_documents, :attaching_conditions, :jsonb, null: true
    add_column :operator_responsibilities, :assigning_conditions, :jsonb, null: true

    reversible do |direction|
      direction.up do
        Rails.application.eager_load!
        migrate_always_apply_conditions
        migrate_booking_conditions_by_group(Tarif, group: :selecting, target: :selecting_conditions)
        migrate_booking_conditions_by_group(Tarif, group: :enabling, target: :enabling_conditions)
        migrate_booking_conditions_by_group(BookingValidation, group: :validating, target: :validating_conditions)
        migrate_booking_conditions_by_group(BookingValidation, group: :enabling, target: :enabling_conditions)
        migrate_booking_conditions_by_group(BookingQuestion, group: :applying, target: :applying_conditions)
        migrate_booking_conditions_by_group(DesignatedDocument, group: :attaching, target: :attaching_conditions)
        migrate_booking_conditions_by_group(OperatorResponsibility, group: :assigning, target: :assigning_conditions)
      end
    end
  end

  protected

  def migrate_always_apply_conditions
    ActiveRecord::Base.connection.execute(<<~SQL.squish)
      UPDATE booking_conditions
      SET type = 'BookingConditions::Always'
      WHERE type = 'BookingConditions::AlwaysApply'
    SQL
  end

  def migrate_booking_conditions_by_group(klass, group:, target:)
    table = Arel::Table.new(:booking_conditions)
    query = table.project(Arel.star)
                 .where(table[:qualifiable_type].eq(klass.sti_name))
                 .where(table[:group].eq(group))

    mapped_conditions = {}
    ActiveRecord::Base.connection.exec_query(query.to_sql).to_a.each do |condition|
      condition.symbolize_keys!
      mapped_conditions[condition[:qualifiable_id]] ||= []
      mapped_conditions[condition[:qualifiable_id]] << migrate_booking_condition_hash(condition)
    end
    mapped_conditions.each do |qualifiable_id, conditions|
      qualifiable = klass.find(qualifiable_id)
      qualifiable.update!(target => conditions)
    end
  end

  def migrate_booking_condition_hash(condition_hash)
    {
      id: Digest::UUID.uuid_v4,
      type: condition_hash[:type],
      organisation_id: condition_hash[:organisation_id],
      compare_value: condition_hash[:compare_value],
      compare_attribute: condition_hash[:compare_attribute],
      compare_operator: condition_hash[:compare_operator],
      _migrated_from: condition_hash
    }
  end
end
