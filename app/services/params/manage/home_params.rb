module Params
  module Manage
    class HomeParams < ApplicationParams
      def permit(params)
        params.require(:home).permit()
      end

      def self.permitted_keys
        [:name, :ref, :house_rules, :janitor,
        tarifs_attributes: TarifParams.permitted_keys + [:id]]
      end
    end
  end
end
