module Manage
  class StayController < BaseController
    load_and_authorize_resource :stay

    # before_action { breadcrumbs.add(Home.model_name.human(count: :other), manage_stays_path) }
    # before_action(only: :new) { breadcrumbs.add(t(:new)) }
    # before_action(only: %i[show edit]) { breadcrumbs.add(@stay.to_s, manage_stay_path(@stay)) }
    # before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

    # def index
    #   respond_with :manage, @stays
    # end

    def show
      respond_with :manage, @stay
    end

    def new
      respond_with :manage, @stay
    end

    def edit
      respond_with :manage, @stay
    end

    def create
      @stay.update(stay_params)
      respond_with :manage, @stay
    end

    def update
      @stay.update(stay_params)
      respond_with :manage, @stay, location: params[:return_path]
    end

    def destroy
      @stay.destroy
      respond_with :manage, @stay, location: manage_booking_path(@stay.booking)
    end

    private

    def stay_params
      Params::Manage::StayParams.new.permit(params)
    end
  end
end
