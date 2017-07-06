class CreateOccupancies < ActiveRecord::Migration[5.1]
  def change
    create_table :occupancies do |t|
      t.datetime :begins_at, null: false, index: true
      t.datetime :ends_at, null: false, index: true
      t.boolean :blocking, null: false, default: false, index: true
      t.references :home, foreign_key: true, null: false

      t.timestamps
    end
  end
end
