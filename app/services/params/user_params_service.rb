module Params
  class UserParamsService < ApplicationParamsService
    def process
      @params.require(:user).permit(:email, :role)
    end
  end
end
