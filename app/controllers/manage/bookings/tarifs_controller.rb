module Manage
  module Bookings
    class TarifsController < ::Manage::TarifsController
      load_and_authorize_resource :booking
      load_and_authorize_resource :tarif, through: :booking, through_association: :booking_copy_tarifs
      load_and_authorize_resource :usage, through: :booking, parent: false

      def index
        # @tarifs = @tarifs.rank(:row_order)
        @suggested_usages = UsageBuilder.new.for_booking(@booking, @booking.home.tarifs)
        respond_with :manage, @usages
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
        TarifParams.permit(params.require('tarif'))
      end
    end
  end
end
