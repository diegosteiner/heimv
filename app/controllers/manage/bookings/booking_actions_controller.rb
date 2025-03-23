# frozen_string_literal: true

module Manage
  module Bookings
    class BookingActionsController < BaseController
      load_and_authorize_resource :booking
      before_action do
        authorize! :manage, @booking
      end

      def prepare
        nil unless booking_action
      end

      def invoke # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        @result = booking_action.invoke(**booking_action_params)

        if @result&.success
          write_booking_log
          redirect_to @result.redirect_proc || manage_booking_path(@booking), notice: t('.success')
        else
          ExceptionNotifier.notify_exception(@result&.error) if defined?(ExceptionNotifier)
          redirect_to manage_booking_path(@booking), alert: @result&.error.presence || t('.failure')
        end
      end

      private

      def write_booking_log
        Booking::Log.log(@booking, trigger: :manager, action: booking_action, user: current_user)
      end

      def booking_action
        @booking_action ||= @booking.booking_flow.manage_action(params[:id]&.to_sym)
        raise ActiveRecord::RecordNotFound if @booking_action.blank?

        @booking_action
      end

      def booking_action_params
        booking_action.invoke_schema&.call(params.to_unsafe_h).to_h
      end
    end
  end
end
