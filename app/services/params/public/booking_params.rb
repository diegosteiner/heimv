module Params
  module Public
    class BookingParams < ApplicationParams
      def call(params, booking)
        permitted_params = if booking.blank? || booking.new_record?
                             self.class.permitted_create_params
                           else
                             self.class.permitted_update_params
                           end
        params.require(:booking).permit(*permitted_params)
      end

      def self.permitted_create_params
        [:organisation, :home_id, :email,
         occupancy_attributes: %i[begins_at ends_at]]
      end

      def self.permitted_update_params
        [:organisation, :definitive_request, :cancellation_reason,
         :committed_request, :event_kind, :approximate_headcount, :remarks,
         customer_attributes: CustomerParams.permitted_params.without(:email)]
      end
    end
  end
end
