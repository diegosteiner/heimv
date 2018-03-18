module Params
  module Manage
    class HomeParams < ApplicationParams
      def call(params)
        params.require(:home).permit(:name, :ref, :house_rules)
      end
    end
  end
end
