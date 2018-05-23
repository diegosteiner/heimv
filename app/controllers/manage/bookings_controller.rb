module Manage
  class BookingsController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :occupancy, through: :booking
    # load_and_authorize_resource :customer, through: :booking
    # load_and_authorize_resource :home, through: :booking
    # load_and_authorize_resource :booking_transition, through: :booking
    # before_action :load_associations, only: %i[index]

    before_action { breadcrumbs.add(Booking.model_name.human(count: :other), manage_bookings_path) }
    before_action(only: :new) { breadcrumbs.add(t(:new)) }
    before_action(only: %i[show edit]) { breadcrumbs.add(@booking.to_s, manage_booking_path(@booking)) }
    before_action(only: :edit) { breadcrumbs.add(t(:edit)) }
    before_action :initialize_view_model, except: %i[index]

    def index
      @bookings = @bookings.includes(:occupancy, :customer, :home, :booking_transitions).order(updated_at: :DESC)
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
      Params::Manage::BookingParams.new.permit(params)
    end
  end
end
