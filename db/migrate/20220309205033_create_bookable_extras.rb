class CreateBookableExtras < ActiveRecord::Migration[7.0]
  def change
    create_table :bookable_extras do |t|
      t.jsonb :title_i18n
      t.jsonb :description_i18n
      t.references :home, null: false, foreign_key: true
      t.references :organisation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
