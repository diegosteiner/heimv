# frozen_string_literal: true

module Manage
  module Bookings
    class UsagesController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :usage, through: :booking

      def index
        @usages = @usages.includes(tarif: %i[prefill_usage_booking_question vat_category])
        @suggested_usages = Usage::Factory.new(@booking).build(preselect: suggest_usages?)

        respond_with :manage, @booking, @usages
      end

      def edit
        respond_with :manage, @booking, @usage
      end

      def create
        @usage.save
        respond_with :manage, @booking, @usage, location: -> { manage_booking_usages_path(@usage.booking) }
      end

      def update_many
        @booking.assign_attributes(booking_usages_params)
        flash_messages = responder_flash_messages(Usage.model_name.human)

        if @booking.usages.all?(&:valid?) && @booking.save
          redirect_to params[:return_to].presence || manage_booking_usages_path(@booking),
                      notice: flash_messages[:notice]
        else
          redirect_to manage_booking_usages_path(@booking), alert: flash_messages[:error]
        end
      end

      def update
        @usage.update(usage_params)
        respond_with :manage, @booking, @usage, location: -> { manage_booking_usages_path(@usage.booking) }
      end

      def destroy
        @usage.destroy
        respond_with :manage, @booking, @usage, location: -> { manage_booking_usages_path(@usage.booking) }
      end

      private

      def suggest_usages?
        @booking.usages.none?(&:persisted?) || params[:suggest_usages].present?
      end

      def usage_params
        UsageParams.new(params.require(:usage)).permitted
      end

      def booking_usages_params
        BookingParams.new(ActionController::Parameters.new(usages_attributes: params[:usages])).permitted
      end
    end
  end
end
