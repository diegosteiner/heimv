class ChangeTarifRelevantTypes < ActiveRecord::Migration[7.0]
  def change
    rename_column :tarifs, :invoice_types, :associated_types

    reversible do |direction|
      direction.up do 
        Tarif.find_each do |tarif|
          if tarif.tenant_visible
            tarif.associated_types.set(Tarif::ASSOCIATED_TYPES.key(::Contract))
                                   else 
            tarif.associated_types = []
          end
          tarif.save
        end
      end
    end

    remove_column :tarifs, :tenant_visible, :boolean
  end
end
