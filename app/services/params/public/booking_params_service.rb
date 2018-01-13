module Params
  module Public
    class BookingParamsService < ApplicationParamsService
      def call(params, create_flag = false)
        permitted_params = (create_flag ? self.class.permitted_create_params : self.class.permitted_update_params)
        params.require(:booking).permit(*permitted_params)
      end

      def self.permitted_create_params
        permitted_update_params.tap do |params|
          params.unshift :home_id
          params.last[:occupancy_attributes] = %i[begins_at ends_at]
        end
      end

      def self.permitted_update_params
        [:organisation,
         customer_attributes: CustomerParamsService.permitted_params]
      end
    end
  end
end
