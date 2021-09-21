# frozen_string_literal: true

module Manage
  class BookingsController < BaseController
    load_and_authorize_resource :booking
    before_action :set_filter, only: :index

    def index
      @bookings = @bookings.where(organisation: current_organisation)
      @bookings = @filter.apply_cached(@bookings.with_default_includes.ordered)
      respond_with :manage, @bookings
    end

    def show
      respond_with :manage, @booking
    end

    def new
      @booking.organisation = current_organisation
      @booking.build_occupancy
      @booking.build_tenant
      respond_with :manage, @booking
    end

    def edit; end

    def import
      result = Import::Csv::OccupancyImporter.new(Home.find(import_params[:home_id])).parse_file import_params[:file]

      if result.ok?
        redirect_to manage_bookings_path, notice: t('.import_success')
      else
        redirect_to manage_bookings_path, alert: t('.import_error')
      end
    end

    def create
      @booking.organisation = current_organisation
      @booking.transition_to ||= BookingStates::OpenRequest
      @booking.save
      respond_with :manage, @booking
    end

    def update
      @booking.update(booking_params) if booking_params
      call_booking_action
      respond_with :manage, @booking
    end

    def destroy
      @booking.destroy
      respond_with :manage, @booking, location: return_to_path(manage_bookings_path)
    end

    private

    def set_filter
      @filter = Booking::Filter.new(default_booking_filter_params.merge(booking_filter_params))
    end

    def call_booking_action
      booking_action&.call(booking: @booking)
    rescue BookingActions::Base::NotAllowed
      @booking.errors.add(:base, :action_not_allowed)
    end

    def booking_action
      BookingActions::Manage.all[params[:booking_action]]
    end

    def booking_params
      BookingParams.new(params[:booking]).permitted
    end

    def booking_filter_params
      Manage::BookingFilterParams.new(params).permitted
    end

    def import_params
      params.require(:import).permit(%i[home_id file])
    end

    def default_booking_filter_params
      { 'current_booking_states' => BookingStates.displayed_by_default }
    end
  end
end
