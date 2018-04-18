class CreateTarifs < ActiveRecord::Migration[5.2]
  def change
    create_table :tarifs do |t|
      t.string :type
      t.string :label
      t.boolean :appliable
      t.belongs_to :booking, type: :uuid, null: true
      t.belongs_to :home, null: true
      t.belongs_to :template_tarif, null: true
      t.string :unit
      t.decimal :price_per_unit
      t.datetime :valid_from, null: true, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :valid_until, null: true
      t.integer :position
      t.string :tarif_group, null: true

      t.timestamps
    end
  end
end
