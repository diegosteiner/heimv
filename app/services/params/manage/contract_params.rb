module Params
  module Manage
    class ContractParams < ApplicationParams
      def permit(params)
        params.require(:contract).permit(*self.class.permitted_keys)
      end

      def self.permitted_keys
        %i[sent_at signed_at title text valid_from valid_until booking_id]
      end
    end
  end
end
