class CreateOrganisations < ActiveRecord::Migration[5.2]
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :ref, unique: true, index: true
      t.jsonb  :options, default: {}

      t.timestamps
    end
  end
end
