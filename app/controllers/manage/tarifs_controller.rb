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

    private

    def tarif_params
      Params::Manage::TarifParams.new.permit(params)
    end
  end
end
