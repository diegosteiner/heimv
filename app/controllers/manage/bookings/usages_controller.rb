module Manage
  module Bookings
    class UsagesController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :usage, through: :booking

      # before_action do
      #   breadcrumbs.add(Booking.model_name.human(count: :other), manage_bookings_path)
      #   breadcrumbs.add(@booking, manage_booking_path(@booking))
      #   breadcrumbs.add(Usage.model_name.human(count: :other), manage_booking_usages_path)
      # end
      # before_action(only: :new) { breadcrumbs.add(t(:new)) }
      # before_action(only: %i[show edit]) { breadcrumbs.add(@usage.to_s, manage_usage_path(@usage)) }
      # before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

      def index
        @usages = @booking.usages + UsageBuilder.new.for_booking(@booking)
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
        respond_with :manage, @booking, @usages, location: manage_booking_usages_path(@booking)
      end

      def update
        @usage.update(usage_params) + UsageBuilder.new.for_booking(@booking)
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
