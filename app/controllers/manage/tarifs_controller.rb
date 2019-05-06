module Manage
  class TarifsController < BaseController
    def create
      @tarif.save
      respond_with :manage, @tarif.parent, @tarif
    end

    def update
      @tarif.update(tarif_params)
      respond_with :manage, @tarif.parent, @tarif
    end

    protected

    def tarif_params
      TarifParams.permit(params.require(:tarif))
    end
  end
end
