# frozen_string_literal: true

module Public
  class OccupanciesController < BaseController
    load_and_authorize_resource :home
    load_and_authorize_resource :occupancy, through: :home
    layout false
    after_action :allow_embed, only: %i[embed]
    before_action :set_calendar, only: %i[calendar index]
    respond_to :json, :ics

    def index
      respond_to do |format|
        format.json { render json: OccupancySerializer.render(@calendar.occupancies) }
        format.ics { render plain: IcalService.new.occupancies_to_ical(@calendar.occupancies) }
      end
    end

    def show
      respond_with :public, @occupancy
    end

    def embed; end

    def calendar
      render json: OccupancyCalendarSerializer.render(@calendar)
    end

    def at
      date = Time.zone.parse(params[:date])
      occupancies = Occupancy.accessible_by(current_ability).merge(@home.occupancies)
      redirect_to OccupancyAtService.new(@home, occupancies).redirect_to(date, manage: can?(:manage, @home))
    end

    private

    def set_calendar
      @calendar = OccupancyCalendar.new(home: @home, window_from: 2.months.ago) if can?(:manage, @home)
      @calendar = OccupancyCalendar.new(home: @home) if @calendar.blank?
    end
  end
end
