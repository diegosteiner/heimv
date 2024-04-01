# frozen_string_literal: true

module Manage
  module Bookings
    class BookingActionsController < BaseController
      load_and_authorize_resource :booking

      def invoke
        authorize! :manage, @booking
        @result = booking_action.invoke

        if @result.success
          write_booking_log
          redirect_to @result&.redirect_proc ? instance_eval(&@result.redirect_proc) : manage_booking_path(@booking),
                      notice: t('.success')
        else
          redirect_to manage_booking_path(@booking), alert: @result.error.presence || t('.failure')
        end
      end

      private

      def write_booking_log
        Booking::Log.log(@booking, trigger: :manager, action: booking_action, user: current_user)
      end

      def booking_action
        @booking_action ||= BookingActions::Manage.all[params[:id]&.to_sym]&.new({ booking: @booking }).tap do |action|
          raise ActiveRecord::RecordNotFound if action.blank?
        end
      end
    end
  end
end
