class CreateBookingPurposes < ActiveRecord::Migration[6.0]
  def change
    create_table :booking_purposes do |t|
      t.references :organisation, null: false, foreign_key: true
      t.string :key
      t.jsonb :title_i18n

      t.timestamps
    end
    add_index :booking_purposes, %i[key organisation_id], unique: true
    rename_column :bookings, :purpose, :purpose_key

    reversible do |direction|
      direction.up do
        Organisation.find_each do |organisation|
          organisation.booking_purposes.create(key: 'camp', title_de: 'Lager')
          organisation.booking_purposes.create(key: 'event', title_de: 'Privater Anlass')
        end

        MarkdownTemplate.find_each do |markdown_template|
          replaced = markdown_template.body_i18n.transform_values { |body| body.gsub('| booking_purpose }}', '}}')}
          markdown_template.update(body_i18n: replaced)
        end
      end
    end
  end
end
