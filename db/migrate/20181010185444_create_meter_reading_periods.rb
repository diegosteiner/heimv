class CreateMeterReadingPeriods < ActiveRecord::Migration[5.2]
  def change
    create_table :meter_reading_periods do |t|
      t.references :tarif, foreign_key: true
      t.references :usage, foreign_key: true, null: true
      t.decimal :start_value
      t.decimal :end_value
      t.datetime :begins_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
