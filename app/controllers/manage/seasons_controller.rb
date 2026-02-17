# frozen_string_literal: true

module Manage
  class SeasonsController < BaseController
    load_and_authorize_resource :season

    def index
      @seasons = @seasons.where(organisation: current_organisation).ordered
      respond_with :manage, @seasons
    end

    def edit
      respond_with :manage, @season
    end

    def create
      @season.organisation = current_organisation
      @season.save
      respond_with :manage, @season, location: -> { manage_seasons_path }
    end

    def update
      @season.update(season_params)
      respond_with :manage, @season, location: -> { manage_seasons_path }
    end

    def destroy
      @season.discarded? ? @season.destroy : @season.discard!
      respond_with :manage, @season, location: -> { manage_seasons_path }
    end

    private

    def season_params
      locale_params = I18n.available_locales.map { |locale| ["label_#{locale}"] }
      params.expect(season: [:begins_at, :ends_at, :status, :public_occupancy_visibility,
                             :max_bookings, :max_occupied_days, locale_params.flatten])
    end
  end
end
