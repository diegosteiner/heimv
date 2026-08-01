# frozen_string_literal: true

class AddTypeToUsages < ActiveRecord::Migration[8.1]
  def change
    add_column :tarifs, :mode, :integer, default: nil, null: true
    add_column :usages, :type, :string, null: true
    rename_column :usages, :presumed_used_units, :quoted_units

    reversible do |direction|
      direction.up do
        Rails.application.eager_load!
        backfill_usage_types
        backfill_tarif_modes
      end
    end

    change_column_null :usages, :type, false
  end

  def backfill_usage_types
    Tarif.subtypes.each_value do |type|
      tarif_id = type.pluck(:id)
      Usage.where(tarif_id:).update_all(type: type::Usage.sti_name) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def backfill_tarif_modes
    Tarifs::OvernightStay.update_all(mode: :nights, prefill_usage_method: :headcount) # rubocop:disable Rails/SkipsModelValidations
  end
end
