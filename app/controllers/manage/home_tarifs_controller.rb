module Manage
  class HomeTarifsController < TarifsController
    load_and_authorize_resource :home
    load_and_authorize_resource :tarif, through: :home, shallow: true

    # before_action do
    #   breadcrumbs.add(Booking.model_name.human(count: :other), manage_bookings_path)
    #   breadcrumbs.add(@tarif.booking, manage_booking_path(@tarif.booking))
    #   breadcrumbs.add(Tarif.model_name.human(count: :other))
    # end
    # before_action(only: :new) { breadcrumbs.add(t(:new)) }
    # before_action(only: %i[show edit]) { breadcrumbs.add(@tarif.to_s, manage_tarif_path(@tarif)) }
    # before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

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
      @tarif.home = @home
      @tarif.save
      respond_with :manage, @tarif
    end

    def update
      @tarif.update(tarif_params)
      respond_with :manage, @tarif
    end

    def destroy
      @tarif.destroy
      respond_with :manage, @tarif, location: manage_home_path(@tarif.home)
    end

    private

    def tarif_params
      Params::Manage::TarifParams.new.permit(params)
    end
  end
end
