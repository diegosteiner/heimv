module Params
  module Manage
    class BookingParams < ApplicationParams
      def permit(params)
        params.require(:booking).permit(*self.class.permitted_keys)
      end

      def self.permitted_keys
        [:home_id, :transition_to, :customer_id, :organisation,
         :committed_request, :event_kind, :approximate_headcount, :remarks, :booking_agent_code,
         occupancy_attributes: %i[id begins_at ends_at],
         customer_attributes: (%i[id] + CustomerParams.permitted_keys)]
      end
    end
  end
end
