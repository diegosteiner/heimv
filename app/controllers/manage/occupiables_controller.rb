# frozen_string_literal: true

module Manage
  class OccupiablesController < BaseController
    load_and_authorize_resource :occupiable

    def index
      @occupiables = @occupiables.where(organisation: current_organisation).order(:created_at)
      respond_with :manage, @occupiables
    end

    def new
      respond_with :manage, @occupiable
    end

    def edit
      respond_with :manage, @occupiable
    end

    def create
      @occupiable.organisation = current_organisation
      @occupiable.update(occupiable_params) unless enforce_limit
      respond_with :manage, @occupiable.becomes(Occupiable), location: manage_occupiables_path
    end

    def update
      @occupiable.update(occupiable_params)
      respond_with :manage, @occupiable.becomes(Occupiable), location: manage_occupiables_path
    end

    def destroy
      @occupiable.destroy
      respond_with :manage, @occupiable, location: manage_occupiables_path
    end

    private

    def enforce_limit
      return false if current_organisation.homes_limit.nil? ||
                      current_organisation.homes_limit < current_organisation.homes.count

      @occupiable.errors.add(:base, :limit_reached)
      true
    end

    def occupiable_params
      OccupiableParams.new(params[:occupiable])
    end
  end
end
