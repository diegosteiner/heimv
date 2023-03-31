# frozen_string_literal: true

module Public
  class OccupanciesController < BaseController
    load_and_authorize_resource :home
    load_and_authorize_resource :occupancy, through: :home
    layout false
    after_action :allow_embed, only: %i[embed]
    before_action :set_calendar, only: %i[calendar index]
    respond_to :json, :ics

    # CAUTION: Used by Gruppenhaus!
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

    private

    def set_calendar
      window_from = current_organisation_user.present? ? 2.months.ago : Time.zone.now.beginning_of_day

      @calendar = OccupancyCalendar.new(organisation: current_organisation, occupiables: @home.occupiables,
                                        window_from: window_from)
    end
  end
end
