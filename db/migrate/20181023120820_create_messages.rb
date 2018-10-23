class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.references :booking, foreign_key: true, type: :uuid
      t.datetime :sent_at
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end
