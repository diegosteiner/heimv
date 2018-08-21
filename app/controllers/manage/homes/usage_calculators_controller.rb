module Manage
  module Homes
    class UsageCalculatorsController < BaseController
      load_and_authorize_resource :home
      load_and_authorize_resource :usage_calculator, through: :home

      def index
        respond_with :manage, @home, @usage_calculators
      end

      def new
        respond_with :manage, @home, @usage_calculator
      end

      def edit
        respond_with :manage, @home, @usage_calculator
      end

      def create
        @usage_calculator.save
        respond_with :manage, @home, @usage_calculator,
                     location: edit_manage_home_usage_calculator_path(@home, @usage_calculator)
      end

      def update
        @usage_calculator.update(usage_calculator_params)
        respond_with :manage, @home, @usage_calculator,
                     location: edit_manage_home_usage_calculator_path(@home, @usage_calculator)
      end

      def destroy
        @usage_calculator.destroy
        respond_with :manage, @home, @usage_calculator,
                     location: manage_home_usage_calculators_path(@home)
      end

      private

      def usage_calculator_params
        UsageCalculatorParams.permit(params.require(:usage_calculator))
      end
    end
  end
end
