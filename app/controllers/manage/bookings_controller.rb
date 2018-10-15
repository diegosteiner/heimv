module Manage
  class BookingsController < BaseController
    load_and_authorize_resource :booking

    def index
      @bookings = @bookings.includes(:occupancy, :customer, :home, :booking_transitions).order(updated_at: :DESC)
      @bookings_by_state = @bookings.group_by(&:state).with_indifferent_access
      respond_with :manage, @bookings
    end

    def show
      respond_with :manage, @booking
    end

    def new
      @booking.build_occupancy
      @booking.build_customer
      respond_with :manage, @booking
    end

    def edit; end

    def create
      @booking.initiator = :tenant
      @booking.strict_validation = false
      @booking.save
      respond_with :manage, @booking
    end

    def update
      @booking.initiator = :tenant
      @booking.strict_validation = false
      @booking.update(booking_params)
      respond_with :manage, @booking
    end

    def destroy
      @booking.destroy
      respond_with :manage, @booking, location: manage_bookings_path
    end

    private

    def initialize_view_model
      @booking_stategry = @booking.booking_strategy
      @view_model = @booking.booking_strategy::ViewModel.new(@booking)
    end

    def booking_params
      BookingParams.permit(params[:booking])
    end
  end
end
