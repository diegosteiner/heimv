module Manage
  class BookingTarifsController < TarifsController
    load_and_authorize_resource :booking
    load_and_authorize_resource :tarif, through: :booking, shallow: true

    # before_action do
    #   breadcrumbs.add(Booking.model_name.human(count: :other), manage_bookings_path)
    #   breadcrumbs.add(@tarif.booking, manage_booking_path(@tarif.booking))
    #   breadcrumbs.add(Tarif.model_name.human(count: :other))
    # end
    # before_action(only: :new) { breadcrumbs.add(t(:new)) }
    # before_action(only: %i[show edit]) { breadcrumbs.add(@tarif.to_s, manage_tarif_path(@tarif)) }
    # before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

    # def index
    #   respond_with :manage, @tarifs
    # end

    def new
      respond_with :manage, @tarif
    end

    def create
      @tarif.save
      respond_with :manage, @tarif
    end

    def update
      @tarif.update(tarif_params)
      respond_with :manage, @tarif
    end

    def destroy
      @tarif.destroy
      respond_with :manage, @tarif, location: manage_booking_path(@tarif.booking)
    end

    private

    def tarif_params
      Params::Manage::TarifParams.new.permit(params)
    end
  end
end
