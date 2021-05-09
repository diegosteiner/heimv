# frozen_string_literal: true

module Manage
  module Homes
    class TarifsController < ::Manage::TarifsController
      load_and_authorize_resource :home
      load_and_authorize_resource :tarif, through: :home

      def index
        respond_with :manage, @tarif
      end

      def new
        @tarif.home = @home
        respond_with :manage, @tarif
      end

      def edit
        @tarif.tarif_selectors.build
        respond_with :manage, @tarif
      end

      def create
        @tarif.home = @home
        @tarif.save
        respond_with :manage, @tarif, location: manage_home_tarif_path(@home, @tarif)
      end

      def update_many
        @home.update(home_tarifs_params)
        respond_with :manage, @home, @tarifs,
                     { location: params[:return_to] || manage_home_tarifs_path(@home) }
                       .merge(responder_flash_messages(Tarif.model_name.human(count: :other)))
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
        TarifParams.new(params.require(:tarif)).permitted
      end

      def home_tarifs_params
        HomeParams.new(ActionController::Parameters.new(tarifs_attributes: params.require(:tarifs))).permitted
      end

      def flash_interpolation_options
        { resource_name: Tarif.model_name.human }
      end
    end
  end
end
