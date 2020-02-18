# frozen_string_literal: true

module Public
  class OccupanciesController < BaseController
    load_and_authorize_resource :home
    load_and_authorize_resource :occupancy, through: :home
    layout false
    after_action :allow_embed, only: %i[embed]
    respond_to :json, :ics

    def show
      respond_with :public, @occupancy
    end

    def index
      @calendar = OccupancyCalendar.new(home: @home)
      @calendar = OccupancyCalendar.new(home: @home, window_from: 2.months.ago) if can?(:manage, @home)

      respond_to do |format|
        format.json { render json: @calendar }
        format.ics { render plain: IcalService.new.generate_from_occupancies(@calendar.occupancies) }
      end
    end

    def embed; end

    def calendar
      # respond_with :public, @calendar
    end
  end
end
