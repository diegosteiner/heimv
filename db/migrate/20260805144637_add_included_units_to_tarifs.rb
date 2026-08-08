# frozen_string_literal: true

class AddIncludedUnitsToTarifs < ActiveRecord::Migration[8.1]
  def change
    change_table :tarifs, bulk: true do |t|
      t.decimal :included_units, null: true
      t.integer :included_units_mode, null: true, default: 0
      t.decimal :minimum, null: true
      t.integer :minimum_mode, null: true, default: 0
    end

    reversible do |direction|
      direction.up do
        migrate_minimums
      end
    end

    change_table :tarifs, bulk: true do |t|
      t.remove :minimum_usage_per_night, type: :decimal, null: true
      t.remove :minimum_usage_total, type: :decimal, null: true
      t.remove :minimum_price_per_night, type: :decimal, null: true
      t.remove :minimum_price_total, type: :decimal, null: true
    end
  end

  # rubocop:disable Rails/SkipsModelValidations
  def migrate_minimums
    table = Tarif.arel_table

    Tarif.where.not(minimum_usage_total: nil).update_all(minimum: table[:minimum_usage_total], minimum_mode: 3)
    Tarif.where.not(minimum_usage_per_night: nil).update_all(minimum: table[:minimum_usage_per_night], minimum_mode: 1)
    Tarif.where.not(minimum_price_total: nil).update_all(minimum: table[:minimum_price_total], minimum_mode: 6)
    Tarif.where.not(minimum_price_per_night: nil).update_all(minimum: table[:minimum_price_per_night], minimum_mode: 4)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
