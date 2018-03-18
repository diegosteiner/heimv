module Params
  module Manage
    class BookingAgentParams < ApplicationParams
      def call(params)
        params.require(:booking_agent).permit(*self.class.permitted_params)
      end

      def self.permitted_params
        %i[name code email]
      end
    end
  end
end
