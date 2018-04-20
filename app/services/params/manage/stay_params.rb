module Params
  module Manage
    class StayParams < ApplicationParams
      def permit(params)
        params.require(:stay).permit(*self.class.permitted_keys)
      end

      def self.permitted_keys
        %i[booking_id tarifs_attributes: TarifParams.permitted_keys + [:id]]
      end
    end
  end
end
