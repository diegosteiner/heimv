module Params
  module Manage
    class TarifParams < ApplicationParams
      def permit(params)
        params.require(:tarif).permit(*self.class.permitted_keys)
      end

      def permit_update_all(params)
        params.dig(:home).permit(tarifs_attributes: (self.class.permitted_keys + [:id]))[:tarifs_attributes]
      end


      def self.permitted_keys
        %i[type label unit price_per_unit position tarif_group]
      end
    end
  end
end
