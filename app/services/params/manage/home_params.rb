module Params
  module Manage
    class HomeParams < ApplicationParams
      def call(params)
        params.require(:home).permit(:name, :ref)
      end
    end
  end
end
