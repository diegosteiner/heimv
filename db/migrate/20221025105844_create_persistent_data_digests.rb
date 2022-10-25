class CreatePersistentDataDigests < ActiveRecord::Migration[7.0]
  def change
    rename_table :data_digests, :data_digest_templates
    create_table :data_digests do |t|
      t.references :data_digest_template, null: false, foreign_key: true
      t.references :organisation, null: false, foreign_key: true
      t.datetime :period_from, precision: nil, null: true
      t.datetime :period_to, precision: nil, null: true
      t.jsonb :data

      t.timestamps
    end

    reversible do |direction|
      direction.up do 
        # rename all types in data_digest_templates
      end
    end
  end
end
