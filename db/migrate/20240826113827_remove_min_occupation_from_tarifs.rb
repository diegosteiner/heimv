class RemoveMinOccupationFromTarifs < ActiveRecord::Migration[7.1]
  def up
    Tarif.where(type: 'Tarifs::MinOccupation').update_all(type: 'Tarifs::Amount')
  end
end
