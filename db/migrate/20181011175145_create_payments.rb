class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.decimal :amount
      t.date :paid_at
      t.string :ref, null: true
      t.references :invoice, foreign_key: true, null: true
      t.references :booking, foreign_key: true, type: :uuid
      t.text :data, null: true
      t.text :remarks, null: true

      t.timestamps
    end
  end
end
