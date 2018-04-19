module Params
  module Public
    class BookingParams < ApplicationParams
      def permit(params)
        permit_create(params)
      end

      def permit_create(params)
        params.require(:booking).permit(self.class.permitted_keys_create)
      end

      def permit_update(params)
        params.require(:booking).permit(self.class.permitted_keys_update)
      end

      def self.permitted_keys_create
        [:organisation, :home_id, :email, :booking_agent_code,
         occupancy_attributes: %i[begins_at ends_at]]
      end

      def self.permitted_keys_update
        [:organisation, :definitive_request, :cancellation_reason, :invoice_address,
         :committed_request, :event_kind, :approximate_headcount, :remarks,
         customer_attributes: CustomerParams.permitted_keys.without(:email)]
      end
    end
  end
end
