# frozen_string_literal: true

module Manage
  class BookingsController < BaseController
    load_and_authorize_resource :booking
    before_action :set_filter, only: :index

    def index
      @bookings = @bookings.where(organisation: current_organisation)
      @bookings = @filter.apply(@bookings.with_default_includes.ordered, cached: true)
      respond_with :manage, @bookings
    end

    def show
      respond_to do |format|
        format.html
        format.json { render json: BookingSerializer.render(@booking) }
      end
    end

    def new
      @booking.organisation = current_organisation
      @booking.build_tenant
      respond_with :manage, @booking
    end

    def edit; end

    def new_import
      render 'import'
    end

    def import
      @result = booking_import
      redirect_to manage_bookings_path, notice: t('.import_success') if @result.ok?
    end

    def create
      @booking.organisation = current_organisation
      @booking.transition_to ||= :open_request
      @booking.save
      Booking::Log.log(@booking, trigger: :manager, user: current_user)
      respond_with :manage, @booking
    end

    def update
      @booking.update(booking_params) if booking_params
      call_booking_action
      Booking::Log.log(@booking, trigger: :manager, action: booking_action, user: current_user)
      respond_with :manage, @booking
    end

    def destroy
      deletion_service = BookingDeletionService.new(current_organisation)
      deletion_service.delete!(@booking)
      respond_with :manage, @booking, location: return_to_path(manage_bookings_path)
    end

    private

    def set_filter
      @filter = Booking::Filter.new(default_booking_filter_params.merge(booking_filter_params))
    end

    def booking_import
      home = current_organisation.homes.find booking_import_params[:home_id]
      headers = booking_import_params[:headers].presence&.split(/[,;]/) || true
      Import::Csv::OccupancyImporter.new(home, csv: { headers: headers }).parse_file(booking_import_params[:file])
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
      Manage::BookingFilterParams.new(params[:filter]).permitted
    end

    def booking_import_params
      params.require(:import).permit(%i[home_id file headers])
    end

    def default_booking_filter_params
      { 'current_booking_states' => BookingStates.displayed_by_default }
    end
  end
end
