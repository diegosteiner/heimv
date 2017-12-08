module Params
  class HomeParamsService < ApplicationParamsService
    def process
      @params.require(:home).permit(:name, :ref)
    end
  end
end
