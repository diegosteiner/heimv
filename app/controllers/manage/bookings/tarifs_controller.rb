module Manage
  module Bookings
    class TarifsController < ::Manage::TarifsController
      load_and_authorize_resource :booking
      load_and_authorize_resource :tarif, through: :booking, parent: false

      # before_action do
      #   breadcrumbs.add(Booking.model_name.human(count: :other), manage_bookings_path)
      #   breadcrumbs.add(@booking, manage_booking_path(@booking))
      #   breadcrumbs.add(Tarif.model_name.human(count: :other))
      # end
      # before_action(only: :new) { breadcrumbs.add(t(:new)) }
      # before_action(only: %i[show edit]) { breadcrumbs.add(@tarif.to_s, manage_booking_tarif_path(@tarif)) }
      # before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

      def index
        @tarifs = @tarifs.rank(:row_order)
        respond_with :manage, @tarifs
      end

      def new
        respond_with :manage, @tarif
      end

      def edit
        respond_with :manage, @tarif
      end

      def create
        @tarif.save
        respond_with :manage, @tarif, location: manage_booking_tarifs_path(@booking)
      end

      def update
        @tarif.update(tarif_params)
        respond_with :manage, @tarif, location: manage_booking_tarifs_path(@booking)
      end

      # def update_many
      #   tarif_ids = params[:tarifs].map(&:id)
      #   @tarifs = Tarif.find(tarif_ids)

      #   Tarif.transaction do
      #     @tarif.each do |tarif|
      #       tarif.update!(TarifParams.permit(params.require(:tarifs)[tarif.id]))
      #     end
      #   end
      # end

      def destroy
        @tarif.destroy
        respond_with :manage, @tarif, location: manage_booking_path(@tarif.booking)
      end

      private

      def tarif_params
        TarifParams.permit(params)
      end
    end
  end
end
