module Params
  module Admin
    class UserParams < ApplicationParams
      def permit(params)
        params.require(:user).permit(:email, :role)
      end
    end
  end
end
