class CreateVatCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :vat_categories do |t|
      t.decimal :percentage, null: false, default: 0.0
      t.jsonb :label_i18n, null: true
      t.references :organisation, null: false, foreign_key: true
      t.string :accounting_vat_code
      t.datetime :discarded_at, index: true

      t.timestamps
    end
  end
end
