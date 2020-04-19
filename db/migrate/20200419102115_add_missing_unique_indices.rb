class AddMissingUniqueIndices < ActiveRecord::Migration[6.0]
def change
    remove_index :markdown_templates, :key
    add_index :markdown_templates, %i[key locale organisation_id], unique: true

    remove_index :usages, :tarif_id
    add_index :usages, %i[tarif_id booking_id], unique: true
  end
end
