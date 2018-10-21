class CreateDeadlines < ActiveRecord::Migration[5.2]
  def change
    create_table :deadlines do |t|
      t.datetime :at
      t.references :booking, foreign_key: true, type: :uuid
      t.references :responsible, index: true, polymorphic: true, null: true
      t.integer :extended, default: 0
      t.boolean :current, default: true

      t.timestamps
    end
  end
end
