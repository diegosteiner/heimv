class CreateBookingReports < ActiveRecord::Migration[5.2]
  def change
    create_table :booking_reports do |t|
      t.string :type
      t.string :label
      t.jsonb :filter_params, default: {}
      t.jsonb :report_params, default: {}

      t.timestamps
    end
  end
end
