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
         customer_attributes: CustomerParams.permitted_params,
         occupancy_attributes: %i[begins_at ends_at]]
      end

      def self.permitted_update_params
        [:organisation, :confirmed_definitive_request,
         customer_attributes: CustomerParams.permitted_params]
      end
    end
  end
end
