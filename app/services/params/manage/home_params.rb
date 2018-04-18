module Params
  module Manage
    class HomeParams < ApplicationParams
      def permit(params)
        params.require(:home).permit(:name, :ref, :house_rules, tarifs_attributes: TarifParams.permitted_keys + [:id])
      end
    end
  end
end
