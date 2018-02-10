module Params
  module Public
    class BookingParamsService < ApplicationParamsService
      def call(params, booking)
        permitted_params = (booking.new_record? ? self.class.permitted_create_params : self.class.permitted_update_params)
        params = params.require(:booking).permit(*permitted_params)
        permit_values(params, booking)
        params
      end

      def self.permitted_create_params
        [:organisation, :home_id, :email,
         customer_attributes: CustomerParamsService.permitted_params,
         occupancy_attributes: %i[begins_at ends_at]]
      end

      def self.permitted_update_params
        [:organisation, :transition_to,
         customer_attributes: CustomerParamsService.permitted_params]
      end

      protected

      def permit_values(params, booking)
        params.delete(:transition_to) unless booking.state_manager.allowed_public_transitions.include?(params[:transition_to])
      end
    end
  end
end
