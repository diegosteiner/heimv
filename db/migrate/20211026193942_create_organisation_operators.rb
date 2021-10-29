class CreateOrganisationOperators < ActiveRecord::Migration[6.1]
  def change
    create_table :organisation_operators do |t|
      t.references :organisation, null: false, foreign_key: true
      t.references :home, null: true, foreign_key: true
      t.references :operator, null: false, foreign_key: true
      t.integer :ordinal, index: true
      t.integer :responsibility, index: true, null: false
      t.text :remarks

      t.timestamps
    end
    reversible do |direction| 
      direction.up do 
        drop_table :home_operators
      end
    end
  end
end
