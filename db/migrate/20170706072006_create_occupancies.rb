class CreateOccupancies < ActiveRecord::Migration[5.1]
  def change
    create_table :occupancies, id: :uuid do |t|
      t.datetime :begins_at, null: false, index: true
      t.datetime :ends_at, null: false, index: true
      # t.boolean :blocking, null: false, default: false, index: true
      t.references :home, foreign_key: true, null: false, index: true
      t.references :booking, index: true, polymorphic: true, type: :uuid
      t.integer :occupancy_type, null: false, default: 0, index: true
      t.text :remarks, null: true

      t.timestamps
    end
  end
end
