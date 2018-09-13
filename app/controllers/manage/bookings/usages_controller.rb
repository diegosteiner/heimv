module Manage
  module Bookings
    class UsagesController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :usage, through: :booking

      def index
        # @usages += UsageBuilder.new(@booking).build # , @booking.home.tarifs.transient)
        @usages.each(&:prefill)
        respond_with :manage, @booking, @usages
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
        @booking.update(booking_usages_params)
        respond_with :manage, @booking, @usages, location: params[:return_to] || manage_booking_usages_path(@booking)
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

      def usage_params
        UsageParams.permit(params.require(:usage))
      end

      def booking_usages_params
        BookingParams.permit(ActionController::Parameters.new(usages_attributes: params.require(:usages)))
      end
    end
  end
end
