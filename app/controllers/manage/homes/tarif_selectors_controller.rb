module Manage
  module Homes
    class TarifSelectorsController < BaseController
      load_and_authorize_resource :home
      load_and_authorize_resource :tarif_selector, through: :home

      def index
        respond_with :manage, @home, @tarif_selectors
      end

      def new
        @tarif_selector.tarif_tarif_selectors.build
        respond_with :manage, @home, @tarif_selector
      end

      def edit
        @tarif_selector.tarif_tarif_selectors.build
        respond_with :manage, @home, @tarif_selector
      end

      def create
        @tarif_selector.save
        respond_with :manage, @home, @tarif_selector,
                     location: edit_manage_home_tarif_selector_path(@home, @tarif_selector)
      end

      def update
        @tarif_selector.update(tarif_selector_params)
        respond_with :manage, @home, @tarif_selector,
                     location: edit_manage_home_tarif_selector_path(@home, @tarif_selector)
      end

      def destroy
        @tarif_selector.destroy
        respond_with :manage, @home, @tarif_selector,
                     location: manage_home_tarif_selectors_path(@home)
      end

      private

      def tarif_selector_params
        TarifSelectorParams.permit(params.require(:tarif_selector))
      end
    end
  end
end
