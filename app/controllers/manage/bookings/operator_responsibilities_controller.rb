# frozen_string_literal: true

module Manage
  module Bookings
    class OperatorResponsibilitiesController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :operator_responsibility, through: :booking

      def new
        respond_with :manage, @booking, @operator_responsibility
      end

      def edit
        respond_with :manage, @operator_responsibility
      end

      def create
        @operator_responsibility.save
        respond_with :manage, @operator_responsibility, location: manage_booking_path(@booking)
      end

      def update
        @operator_responsibility.update(operator_responsibility_params)
        respond_with :manage, @operator_responsibility, location: manage_booking_path(@booking)
      end

      def destroy
        @operator_responsibility.destroy
        respond_with :manage, @operator_responsibility, location: manage_booking_path(@booking)
      end

      private

      def operator_responsibility_params
        params.require(:operator_responsibility).permit(%i[responsibility operator_id remarks])
      end
    end
  end
end
