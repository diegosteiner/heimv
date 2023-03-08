# frozen_string_literal: true

module Manage
  class OccupanciesController < BaseController
    load_and_authorize_resource :occupiable
    load_and_authorize_resource :occupancy, through: :occupiable, shallow: true

    def index
      @occupancies = @occupancies.ordered.ends_at(after: Time.zone.now)
      @occupancies = @occupancies.closed if params[:all].blank?
      respond_with :manage, @occupancies
    end

    def show
      respond_with :public, @occupancy
    end

    def new
      @occupancy.assign_attributes(occupiable: @occupiable, linked: false, occupancy_type: :closed)
      respond_with :manage, @occupancy
    end

    def edit
      respond_with :manage, @occupancy
    end

    def create
      @occupancy.update(occupiable: @occupiable, occupancy_type: :closed)
      respond_with :manage, @occupancy, location: manage_occupiable_occupancies_path(@occupiable)
    end

    def update
      @occupancy.update(occupancy_params)
      respond_with :manage, @occupancy, location: manage_occupiable_occupancies_path(@occupancy.occupiable)
    end

    def destroy
      @occupancy.destroy
      respond_with :manage, @occupancy, location: manage_occupiable_occupancies_path(@occupancy.occupiable)
    end

    private

    def occupancy_params
      OccupancyParams.new(params.require(:occupancy)).permitted
    end
  end
end
