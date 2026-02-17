class CreateSeasons < ActiveRecord::Migration[8.1]
  def change
    create_table :seasons do |t|
      t.references :organisation, null: false, foreign_key: true
      t.jsonb :label_i18n, default: {}
      t.datetime :begins_at, null: false
      t.datetime :ends_at, null: false
      t.integer :public_occupancy_visibility, null: false
      t.integer :status, null: false
      t.integer :max_bookings, null: true
      t.integer :max_occupied_days, null: true

      t.datetime :discarded_at, null: true
      t.timestamps
    end

    add_reference :bookings, :season, null: true, foreign_key: { to_table: :seasons }
  end
end
