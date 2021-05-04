class AddI18nColumnsToTarifs < ActiveRecord::Migration[6.1]
  def change
    rename_column :tarifs, :label, :original_label
    rename_column :tarifs, :unit, :original_unit
    add_column :tarifs, :label_i18n, :jsonb, default: {}
    add_column :tarifs, :unit_i18n, :jsonb, default: {}
    reversible do |direction|
      direction.up do 
        Tarif.find_each do |tarif|
          Mobility.with_locale(tarif.organisation.locale) do
            tarif.update(label: tarif.original_label, unit: tarif.original_unit)
          end
        end
      end
    end
    remove_column :tarifs, :original_label, :string
    remove_column :tarifs, :original_unit, :string
    Tarif.reset_column_information
  end
end
