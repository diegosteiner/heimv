module Params
  class CustomerParamsService < ApplicationParamsService
    def process
      @params.require(:customer).permit(*self.class.permitted_params)
    end

    def self.permitted_params
      %i[first_name last_name street_address zipcode city]
    end
  end
end
