module Params
  class UserParamsService < ApplicationParamsService
    def call(params)
      params.require(:user).permit(:email, :role)
    end
  end
end
