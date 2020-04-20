# frozen_string_literal: true

module Public
  class OccupanciesController < BaseController
    load_and_authorize_resource :home
    load_and_authorize_resource :occupancy, through: :home
    layout false
    after_action :allow_embed, only: %i[embed]
    before_action :set_calendar, only: %i[calendar index]
    respond_to :json, :ics

    def show
      respond_with :public, @occupancy
    end

    def index
      respond_to do |format|
        format.json { render json: @calendar.occupancies }
        format.ics { render plain: IcalService.new.generate_from_occupancies(@calendar.occupancies) }
      end
    end

    def embed; end

    def calendar
      render json: @calendar
    end

    def at
      booking_params = BookingParams::Create.new(params[:booking]).permitted
      if can?(:manage, @home)
        at = Time.zone.parse(booking_params.dig(:occupancy_attributes, :begins_at))
        redirect_to manage_bookings_path(filter_for_date(at))
      else
        redirect_to new_public_booking_path(booking: booking_params)
      end
    end

    private

    def filter_for_date(at)
      {
        homes: [@home.id],
        occupancy_params: { begins_at_before: at.end_of_day, ends_at_after: at.beginning_of_day }
      }
    end

    def set_calendar
      @calendar = OccupancyCalendar.new(home: @home, window_from: 2.months.ago) if can?(:manage, @home)
      @calendar = OccupancyCalendar.new(home: @home) if @calendar.blank?
    end
  end
end
