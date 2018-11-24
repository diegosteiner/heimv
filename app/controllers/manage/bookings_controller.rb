module Manage
  class BookingsController < BaseController
    load_and_authorize_resource :booking

    def index
      @filter = Booking::Filter.new(booking_filter_params)
      @bookings = @filter.reduce(@bookings.includes(:occupancy, :tenant, :home, :booking_transitions)
                                          .joins(:occupancy)
                                          .order(Occupancy.arel_table[:begins_at]))
      @bookings_by_state = @bookings.group_by(&:state).with_indifferent_access
      respond_with :manage, @bookings
    end

    def show
      respond_with :manage, @booking
    end

    def new
      @booking.build_occupancy
      @booking.build_tenant
      respond_with :manage, @booking
    end

    def edit; end

    def create
      # @booking.initiator = :tenant
      @booking.save
      respond_with :manage, @booking
    end

    def update
      # @booking.initiator = :tenant
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

    def booking_filter_params
      params[:filter]&.permit(:begins_at, :ends_at, :tenant, :ref, booking_states: [], homes: []) || {}
    end
  end
end
