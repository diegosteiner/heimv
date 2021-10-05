# frozen_string_literal: true

module Manage
  module Bookings
    class BookingOperatorsController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :booking_operator, through: :booking

      def new
        respond_with :manage, @booking, @booking_operator
      end

      def edit
        respond_with :manage, @booking_operator
      end

      def create
        @booking_operator.save
        respond_with :manage, @booking_operator, location: manage_booking_path(@booking)
      end

      def update
        @booking_operator.update(booking_operator_params)
        respond_with :manage, @booking_operator, location: manage_booking_path(@booking)
      end

      def destroy
        @booking_operator.destroy
        respond_with :manage, @booking_operator, location: manage_booking_path(@booking)
      end

      private

      def booking_operator_params
        params.require(:booking_operator).permit(%i[responsibility operator_id remarks])
      end
    end
  end
end
