# frozen_string_literal: true

module Manage
  class HomesController < BaseController
    load_and_authorize_resource :home

    def index
      @homes = @homes.where(organisation: current_organisation).order(:created_at)
      respond_with :manage, @homes
    end

    def show
      respond_with :manage, @home
    end

    def new
      respond_with :manage, @home
    end

    def edit
      respond_with :manage, @home
    end

    def create
      @home.organisation = current_organisation
      @home.update(home_params) unless enforce_limit
      respond_with :manage, @home
    end

    def update
      @home.update(home_params)
      respond_with :manage, @home, location: params[:return_path]
    end

    def destroy
      @home.destroy
      respond_with :manage, @home, location: manage_homes_path
    end

    private

    def enforce_limit
      return false if current_organisation.homes_limit.nil? ||
                      current_organisation.homes_limit < current_organisation.homes.count

      @home.errors.add(:base, :limit_reached)
      true
    end

    def home_params
      HomeParams.new(params[:home])
    end
  end
end
