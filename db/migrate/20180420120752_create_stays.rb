class CreateStays < ActiveRecord::Migration[5.2]
  def change
    create_table :stays do |t|
      t.belongs_to :booking, type: :uuid

      t.timestamps
    end
  end
end
