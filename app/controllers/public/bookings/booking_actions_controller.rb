# frozen_string_literal: true

module Public
  module Bookings
    class BookingActionsController < BaseController
      before_action :set_booking

      def prepare
        nil unless booking_action
      end

      def invoke # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        @result = booking_action.invoke(**booking_action_params)

        if @result&.success
          write_booking_log
          redirect_to @result.redirect_proc || public_booking_path(@booking.token), notice: t('.success')
        else
          ExceptionNotifier.notify_exception(@result&.error) if defined?(ExceptionNotifier)
          redirect_to public_booking_path(@booking.token), alert: @result&.error.presence || t('.failure')
        end
      end

      private

      def write_booking_log
        Booking::Log.log(@booking, trigger: :tenant, action: booking_action, user: current_user)
      end

      def set_booking
        @booking = current_organisation.bookings.find_by!(token: params[:public_booking_id])
      end

      def booking_action
        @booking_action ||= @booking.booking_state.public_actions.find { it.to_sym == params[:id]&.to_sym }
        raise ActiveRecord::RecordNotFound if @booking_action.blank?

        @booking_action
      end

      def booking_action_params
        booking_action.class.params_schema&.call(params.to_unsafe_h).to_h
      end
    end
  end
end
