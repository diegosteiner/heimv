class CreateTarifUsageCalculators < ActiveRecord::Migration[5.2]
  def change
    create_table :tarif_usage_calculators do |t|
      t.references :tarif, foreign_key: true
      t.references :usage_calculator, foreign_key: true
      t.boolean :perform_select, default: true
      t.boolean :perform_calculate, default: true
      t.string :distinction
      t.jsonb :params

      t.timestamps
    end
  end
end
