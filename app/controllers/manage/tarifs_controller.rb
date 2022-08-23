# frozen_string_literal: true

module Manage
  class TarifsController < BaseController
    def create
      @tarif.save
      respond_with :manage, @tarif.home, @tarif
    end

    def update
      @tarif.update(tarif_params)
      respond_with :manage, @tarif.home, @tarif
    end

    protected

    def tarif_params
      TarifParams.new(params.require(:tarif)).permitted
    end
  end
end
