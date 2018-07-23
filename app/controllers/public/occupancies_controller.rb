# frozen_string_literal: true

module Public
  class OccupanciesController < BaseController
    load_and_authorize_resource :home
    load_and_authorize_resource :occupancy, through: :home
    layout false
    respond_to :json

    def show
      respond_with :public, @occupancy
    end

    def index
      respond_with :public, @occupancies.window
    end

    def calendar
      # @calendar = OccupancyCalendarSerializer.new(@occupancies).serializable_hash
      # respond_with :public, @calendar
    end
  end
end
