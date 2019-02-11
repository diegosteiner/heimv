module Manage
  class BookingsController < BaseController
    load_and_authorize_resource :booking

    def index
      @filter = Booking::Filter.new(booking_filter_params)
      @bookings = @filter.reduce(@bookings.includes(:occupancy, :tenant, :home, :booking_transitions)
                                          .joins(:occupancy)
                                          .order(Occupancy.arel_table[:begins_at]))
      # @bookings_by_state = @bookings.group_by(&:state).with_indifferent_access
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
      @booking.save
      respond_with :manage, @booking
    end

    def update
      @booking.update(booking_params) if booking_params
      @organisation.booking_strategy::BookingActions::Manage[booking_action]&.new(@booking)&.call if booking_action
      respond_with :manage, @booking
    end

    def destroy
      @booking.destroy
      respond_with :manage, @booking, location: manage_bookings_path
    end

    private

    def booking_params
      BookingParams.permit(params[:booking])
    end

    def booking_action
      params[:booking_action]
    end

    def booking_filter_params
      params[:filter]&.permit(:begins_at, :ends_at, :tenant, :ref, booking_states: [], homes: []) || {}
    end
  end
end
