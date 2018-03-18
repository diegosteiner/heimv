module Params
  module Admin
    class UserParams < ApplicationParams
      def call(params)
        params.require(:user).permit(:email, :role)
      end
    end
  end
end
