class RemoveHomeIdFromTarifs < ActiveRecord::Migration[7.0]
  def change
    reversible do |direction|
      direction.up do
        Tarif.where.not(home_id: nil).find_each do |tarif|
          home_condition = BookingConditions::Occupiable.new(qualifiable: tarif, distinction: tarif.home_id)
          tarif.update!(enabling_conditions: [home_condition])
        end
      end
    end

    remove_column :tarifs, :home_id
  end
end
