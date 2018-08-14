class CreateUsageCalculators < ActiveRecord::Migration[5.2]
  def change
    create_table :usage_calculators do |t|
      t.references :home, foreign_key: true
      t.string :type, index: true

      t.timestamps
    end
  end
end
