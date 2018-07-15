module Manage
  class TarifsController < BaseController
    self.abstract_class = true

    def create
      @tarif.save
      respond_with :manage, @tarif.parent, @tarif
    end

    def update
      @tarif.update(tarif_params)
      respond_with :manage, @tarif.parent, @tarif
    end

    private

    def tarif_params
      TarifParams.permit(params.require(:tarif))
    end
  end
end
