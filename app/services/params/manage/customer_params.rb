module Params
  module Manage
    class CustomerParams < ApplicationParams
      def permit(params)
        params.require(:customer).permit(*self.class.permitted_keys)
      end

      def self.permitted_keys
        Params::Public::CustomerParams.permitted_keys + %i[reservations_allowed]
      end
    end
  end
end
