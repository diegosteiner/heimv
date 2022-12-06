# frozen_string_literal: true

module Manage
  class TarifsController < BaseController
    load_and_authorize_resource :tarif

    def index
      @tarifs = @tarifs.where(organisation: current_organisation).ordered
      # @tarifs = @tarifs.where(home_id: params[:home_id]) if params[:home_id]
      respond_with :manage, @tarifs
    end

    def new
      tarif_to_clone = current_organisation.tarifs.find(params[:clone]) if params[:clone]
      @tarif = tarif_to_clone.dup if tarif_to_clone.present?
      respond_with :manage, @tarif
    end

    def edit
      @tarif.selecting_conditions.build
      @tarif.enabling_conditions.build
      respond_with :manage, @tarif
    end

    def create
      @tarif.update(organisation: current_organisation)
      respond_with :manage, @tarif, location: edit_manage_tarif_path(@tarif)
    end

    def import
      if params[:file].present?
        Import::Csv::TarifImporter.new(current_organisation).parse(params[:file].read.force_encoding('UTF-8'))
      end

      redirect_to manage_tarifs_path
    end

    def update_many
      @tarifs = Tarif.where(organisation: current_organisation)
      @updated_tarifs = (tarifs_params[:tarifs]&.values || []).map do |tarif_params|
        @tarifs.find_by(id: tarif_params[:id])&.tap do |tarif|
          tarif.update(tarif_params)
        end
      end
      respond_with :manage, @updated_tarifs, location: manage_tarifs_path
    end

    def update
      @tarif.update(tarif_params)
      respond_with :manage, @tarif, location: edit_manage_tarif_path(@tarif)
    end

    def destroy
      @tarif.destroy
      respond_with :manage, @tarif, location: manage_tarifs_path
    end

    private

    def tarif_params
      TarifParams.new(params.require(:tarif)).permitted
    end

    def tarifs_params
      params.permit(tarifs: [TarifParams.permitted_keys + [:id]])
    end
  end
end
