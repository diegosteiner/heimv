module Params
  class HomeParamsService < ApplicationParamsService
    def call(params)
      params.require(:home).permit(:name, :ref)
    end
  end
end
