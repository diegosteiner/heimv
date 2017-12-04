module Params
  class ApplicationParamsService
    def initialize(params, user)
      @params = params
      @user = user
    end

    def process; end
  end
end
