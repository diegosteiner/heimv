class CreateHomes < ActiveRecord::Migration[5.1]
  def change
    create_table :homes do |t|
      t.string :name
      t.string :ref
      t.string :place
      t.text :janitor
      t.boolean :requests_allowed, default: false

      t.timestamps
    end
    add_index :homes, :ref, unique: true
  end
end
