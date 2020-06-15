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
      bookings = Booking.accessible_by(current_ability).merge(@home.bookings)
      redirect_to BookingAtService.new(@home, bookings).at(Time.zone.parse(params[:date]), manage: can?(:manage, @home))
    end

    private

    def set_calendar
      @calendar = OccupancyCalendar.new(home: @home, window_from: 2.months.ago) if can?(:manage, @home)
      @calendar = OccupancyCalendar.new(home: @home) if @calendar.blank?
    end
  end
end
