# frozen_string_literal: true

module Manage
  module Homes
    class HomeOperatorsController < BaseController
      load_and_authorize_resource :home
      load_and_authorize_resource :home_operator, through: :home

      def new
        respond_with :manage, @booking, @home_operator
      end

      def edit
        respond_with :manage, @home_operator
      end

      def create
        @home_operator.save
        respond_with :manage, @home_operator, location: manage_booking_path(@booking)
      end

      def update
        @home_operator.update(home_operator_params)
        respond_with :manage, @home_operator, location: manage_booking_path(@booking)
      end

      def destroy
        @home_operator.destroy
        respond_with :manage, @home_operator, location: manage_booking_path(@booking)
      end

      private

      def home_operator_params
        params.require(:home_operator).permit(%i[responsibility operator_id])
      end
    end
  end
end
