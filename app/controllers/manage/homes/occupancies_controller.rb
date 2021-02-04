# frozen_string_literal: true

module Manage
  module Homes
    class OccupanciesController < BaseController
      load_and_authorize_resource :home
      load_and_authorize_resource :occupancy, through: :home

      def show
        respond_with :public, @occupancy
      end

      def index
        respond_with :manage, @occupancy
      end

      def new
        @occupancy.home = @home
        respond_with :manage, @occupancy
      end

      def edit
        respond_with :manage, @occupancy
      end

      def create
        @occupancy.home = @home
        @occupancy.save
        respond_with :manage, @occupancy, location: manage_home_occupancies_path(@home)
      end

      def update
        @occupancy.update(occupancy_params)
        respond_with :manage, @occupancy, location: manage_home_occupancies_path(@home)
      end

      def destroy
        @occupancy.destroy
        respond_with :manage, @occupancy, location: manage_home_occupancies_path(@home)
      end

      private

      def occupancy_params
        OccupancyParams.new(params.require(:occupancy))
      end
    end
  end
end
