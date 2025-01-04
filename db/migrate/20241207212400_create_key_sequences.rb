class CreateKeySequences < ActiveRecord::Migration[8.0]
  def change
    create_table :key_sequences do |t|
      t.string :key, null: false
      t.references :organisation, null: false, foreign_key: true
      t.integer :year, null: true
      t.integer :value, null: false, default: 0

      t.timestamps
    end
    add_index :key_sequences, [:key, :year, :organisation_id], unique: true
  end
end
