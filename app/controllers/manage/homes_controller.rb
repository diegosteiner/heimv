# frozen_string_literal: true

module Manage
  class HomesController < BaseController
    load_and_authorize_resource :home

    def index
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
      @home.update(home_params)
      @home.house_rules.attach(home_params[:house_rules]) if home_params[:house_rules].present?
      respond_with :manage, @home
    end

    def update
      @home.update(home_params)
      @home.house_rules.attach(home_params[:house_rules]) if home_params[:house_rules].present?
      respond_with :manage, @home, location: params[:return_path]
    end

    def destroy
      @home.destroy
      respond_with :manage, @home, location: manage_homes_path
    end

    private

    def home_params
      HomeParams.new(params[:home])
    end
  end
end
