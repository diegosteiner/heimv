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
      if can?(:manage, @home)
        at = Time.zone.parse(params.require(:booking).require(:occupancy_attributes).require(:begins_at))
        filter = {
          homes: [@home.id],
          occupancy_params: { begins_at_before: at.end_of_day, ends_at_after: at.beginning_of_day }
        }
        redirect_to manage_bookings_path(filter: filter)
      else
        redirect_to new_public_booking_path(params.permit!)
      end
    end

    private

    def set_calendar
      @calendar = OccupancyCalendar.new(home: @home, window_from: 2.months.ago) if can?(:manage, @home)
      @calendar ||= OccupancyCalendar.new(home: @home)
    end
  end
end
