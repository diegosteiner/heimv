class CreateTarifUsageCalculators < ActiveRecord::Migration[5.2]
  def change
    create_table :tarif_usage_calculators do |t|
      t.references :tarif, foreign_key: true
      t.references :usage_calculator, foreign_key: true
      t.string :role
      t.jsonb :params

      t.timestamps
    end
  end
end
