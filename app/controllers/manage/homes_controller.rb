module Manage
  class HomesController < BaseController
    load_and_authorize_resource :home

    before_action { breadcrumbs.add(Home.model_name.human(count: :other), manage_homes_path) }
    before_action(only: :new) { breadcrumbs.add(t(:new)) }
    before_action(only: %i[show edit]) { breadcrumbs.add(@home.to_s, manage_home_path(@home)) }
    before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

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
      respond_with :manage, @home
    end

    def destroy
      @home.destroy
      respond_with :manage, @home, location: manage_homes_path
    end

    private

    def home_params
      Params::Manage::HomeParams.new.permit(params)
    end
  end
end
