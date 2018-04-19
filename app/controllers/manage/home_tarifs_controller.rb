module Manage
  class HomeTarifsController < TarifsController
    load_and_authorize_resource :home
    load_and_authorize_resource :tarif, through: :home, parent: false

    before_action do
      breadcrumbs.add(Home.model_name.human(count: :other), manage_bookings_path)
      breadcrumbs.add(@home, manage_home_path(@home))
      breadcrumbs.add(Tarif.model_name.human(count: :other))
    end
    before_action(only: :new) { breadcrumbs.add(t(:new)) }
    before_action(only: %i[show edit]) { breadcrumbs.add(@tarif.to_s, manage_home_tarif_path(home_id: @home.to_param, tarif: @tarif)) }
    before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

    def index
      respond_with :manage, @home, @tarifs
    end

    def new
      @tarif = Tarif.new
      @tarif.home = @home
      respond_with :manage, @tarif
    end

    def show
      respond_with :manage, @tarif
    end

    def create
      @tarif = Tarif.new(tarif_params)
      @tarif.home = @home
      @tarif.save
      respond_with :manage, @tarif, location: manage_home_tarifs_path(@home)
    end

    def edit
      @tarif = Tarif.find(params[:id])
      respond_with :manage, @home, @tarif
    end

    def update
      @tarif.update(tarif_params)
      respond_with :manage, @tarif, location: manage_home_tarifs_path(@home)
    end

    def destroy
      @tarif.destroy
      respond_with :manage, @tarif, location: manage_home_tarifs_path(@home)
    end

    private

    def tarif_params
      Params::Manage::TarifParams.new.permit(params)
    end
  end
end
