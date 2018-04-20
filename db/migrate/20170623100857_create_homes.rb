class CreateHomes < ActiveRecord::Migration[5.1]
  def change
    create_table :homes do |t|
      t.string :name
      t.string :ref
      t.text :janitor

      t.timestamps
    end
    add_index :homes, :ref, unique: true
  end
end
