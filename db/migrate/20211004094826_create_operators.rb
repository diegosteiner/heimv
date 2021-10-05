class CreateOperators < ActiveRecord::Migration[6.1]
  def change
    create_table :operators do |t|
      t.string :name
      t.string :email
      t.text :contact_info
      t.references :organisation, null: false, foreign_key: true

      t.timestamps
    end
    create_table :booking_operators do |t|
      t.references :booking, null: false, foreign_key: true, type: :uuid
      t.references :operator, null: false, foreign_key: true
      t.integer :responsibility
      t.text :remark

      t.timestamps
    end
    add_index :booking_operators, :responsibility
  end
end
