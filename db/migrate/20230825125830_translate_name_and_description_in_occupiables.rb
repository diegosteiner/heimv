class TranslateNameAndDescriptionInOccupiables < ActiveRecord::Migration[7.0]
  def change
    add_column :occupiables, :name_i18n, :jsonb
    add_column :occupiables, :description_i18n, :jsonb

    reversible do |direction|
      direction.up do 
        Occupiable.reset_column_information
        Occupiable.find_each do |occupiable|
          occupiable.update(name_de: occupiable[:name], description_de: occupiable[:description])
        end
      end
    end

    remove_column :occupiables, :name, :string
    remove_column :occupiables, :description, :text
  end
end
