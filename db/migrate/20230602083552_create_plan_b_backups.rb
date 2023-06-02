class CreatePlanBBackups < ActiveRecord::Migration[7.0]
  def change
    create_table :plan_b_backups do |t|
      t.references :organisation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
