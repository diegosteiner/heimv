class CreateDesignatedDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :designated_documents do |t|
      t.integer :designation, default: 0
      t.string :locale
      t.references :attached_to, null: true, polymorphic: true, index: true

      t.timestamps
    end
  end
end
