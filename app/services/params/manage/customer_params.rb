module Params
  module Manage
    class CustomerParams < ApplicationParams
      def call(params)
        params.require(:customer).permit(*self.class.permitted_params)
      end

      def self.permitted_params
        Params::Public::CustomerParams.permitted_params + %i[reservations_allowed]
      end
    end
  end
end
