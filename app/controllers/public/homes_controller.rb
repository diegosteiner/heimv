# frozen_string_literal: true

module Public
  class HomesController < BaseController
    load_and_authorize_resource :home

    def index
      @homes = @homes.where(organisation: current_organisation)
      respond_with :public, @homes
    end

    def show
      respond_with :manage, @home
    end
  end
end
