module Params
  class ApplicationParamsService
    def initialize(params, current_user)
      @params = params
      @current_user = current_user
    end

    def process; end

    def permitted_params; end
  end
end
