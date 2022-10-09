class AddOrganisationToTarifs < ActiveRecord::Migration[7.0]
  def change
    add_reference :tarifs, :organisation, null: true, foreign_key: true

    Tarif.find_each do |tarif|
      tarif.update(organisation: tarif.home&.organisation)
    end

    change_column_null(:tarifs, :home_id, true)
    change_column_null(:tarifs, :organisation_id, false)
  end
end
