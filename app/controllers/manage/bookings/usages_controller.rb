# frozen_string_literal: true

module Manage
  module Bookings
    class UsagesController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :usage, through: :booking

      def index
        @usages = @usages.includes(:tarif)
        respond_to do |format|
          format.html
          format.pdf do
            send_data Export::Pdf::UsageReportPdf.new(@booking).render_document,
                      filename: "#{@booking.ref}.pdf", type: 'application/pdf', disposition: :inline
          end
        end
      end

      def show
        respond_with :manage, @booking, @usage
      end

      def edit
        respond_with :manage, @booking, @usage
      end

      def create
        @usage.save
        respond_with :manage, @booking, @usage, location: manage_booking_usages_path(@usage.booking)
      end

      def update_many
        @booking.assign_attributes(booking_usages_params)
        set_usage_flags
        @booking.save!
        return_to = params[:return_to] || manage_booking_usages_path(@booking)
        respond_with :manage, @booking, @usages,
                     responder_flash_messages(Usage.model_name.human(count: :other)).merge(location: return_to)
      end

      def update
        @usage.update(usage_params)
        respond_with :manage, @booking, @usage, location: manage_booking_usages_path(@usage.booking)
      end

      def destroy
        @usage.destroy
        respond_with :manage, @booking, @usage, location: manage_booking_usages_path(@usage.booking)
      end

      private

      def set_usage_flags
        @booking.usages_entered ||= params[:usages_entered].present?
        @booking.usages_presumed ||= params[:usages_presumed].present?
      end

      def back_url
        params[:return_to] || manage_booking_usages_path(@booking)
      end

      def usage_params
        UsageParams.new(params.require(:usage))
      end

      def booking_usages_params
        BookingParams.new(ActionController::Parameters.new(usages_attributes: params[:usages]))
      end
    end
  end
end
