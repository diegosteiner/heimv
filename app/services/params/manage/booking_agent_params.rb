module Params
  module Manage
    class BookingAgentParams < ApplicationParams
      def permit(params)
        params.require(:booking_agent).permit(*self.class.permitted_keys)
      end

      def self.permitted_keys
        %i[name code email]
      end
    end
  end
end
