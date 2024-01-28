# frozen_string_literal: true

module Manage
  module Bookings
    class BookingActionsController < BaseController
      load_and_authorize_resource :booking

      def call
        redirect_to = call_booking_action
        write_booking_log
        respond_with :manage, @booking, location: redirect_to
      end

      private

      def preparation_service
        @preparation_service ||= BookingPreparationService.new(current_organisation)
      end

      def write_booking_log
        Booking::Log.log(@booking, trigger: :manager, action: booking_action, user: current_user)
      end

      def call_booking_action
        result = booking_action&.call(booking: @booking)
        instance_eval(&result.redirect_proc) if result&.redirect_proc.present?
      rescue BookingActions::Base::NotAllowed
        @booking.errors.add(:base, :action_not_allowed)
        nil
      end

      def booking_action
        BookingActions::Manage.all[params[:id].presence || params[:booking_action].presence]
      end
    end
  end
end
