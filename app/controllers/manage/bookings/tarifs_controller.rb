# frozen_string_literal: true

module Manage
  module Bookings
    class TarifsController < ::Manage::TarifsController
      load_and_authorize_resource :booking
      load_and_authorize_resource :tarif, through: :booking, through_association: :booking_copy_tarifs
      # load_and_authorize_resource :usage, through: :booking, parent: false

      def index
        @usages = @booking.usages.to_a
        @suggested_usages = Usage::Factory.new(@booking).preselect
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

      def destroy
        @tarif.destroy
        respond_with :manage, @tarif, location: manage_booking_path(@tarif.booking)
      end
    end
  end
end
