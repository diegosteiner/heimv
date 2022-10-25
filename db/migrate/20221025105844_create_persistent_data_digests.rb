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
        DataDigestTemplate.where(type: 'DataDigests::Booking').update_all(type: 'DataDigestTemplates::Booking')
        DataDigestTemplate.where(type: 'DataDigests::InvoicePart').update_all(type: 'DataDigestTemplates::InvoicePart')
        DataDigestTemplate.where(type: 'DataDigests::Payment').update_all(type: 'DataDigestTemplates::Payment')
      end
    end
  end
end
