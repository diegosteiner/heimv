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
      @home.update(home_params)
      @home.house_rules.attach(home_params[:house_rules])
      respond_with :manage, @home
    end

    def update
      @home.update(home_params)
      @home.house_rules.attach(home_params[:house_rules])
      respond_with :manage, @home, location: params[:return_path]
    end

    def destroy
      @home.destroy
      respond_with :manage, @home, location: manage_homes_path
    end

    private

    def home_params
      HomeParams.permit(params[:home])
    end
  end
end
