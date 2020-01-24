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
      @occupancies = @occupancies.window.blocking

      respond_to do |format|
        format.json { render json: @occupancies.to_json }
        format.ics { render plain: IcalService.new.generate_from_occupancies(@occupancies) }
      end
    end

    def embed; end

    def calendar
      # @calendar = OccupancyCalendarSerializer.new(@occupancies).serializable_hash
      # respond_with :public, @calendar
    end
  end
end
