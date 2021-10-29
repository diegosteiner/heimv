# frozen_string_literal: true

module Manage
  class OperatorResponsibilitiesController < BaseController
    load_and_authorize_resource :operator_responsibility
    before_action :set_homes, only: %i[new edit]
    before_action :set_operators, only: %i[new edit index]

    def index
      @operator_responsibilities = @operator_responsibilities.where(organisation: current_organisation).ordered
      respond_with :manage, @operator_responsibilities
    end

    def new
      respond_with :manage, @operator_responsibility
    end

    def edit
      respond_with :manage, @operator_responsibility
    end

    def create
      @operator_responsibility.organisation = current_organisation
      @operator_responsibility.update(operator_responsibility_params)
      respond_with :manage, @operator_responsibility, location: manage_operator_responsibilities_path
    end

    def update
      @operator_responsibility.update(operator_responsibility_params)
      respond_with :manage, @operator_responsibility, location: manage_operator_responsibilities_path
    end

    def destroy
      @operator_responsibility.destroy
      respond_with :manage, @operator_responsibility, location: manage_operator_responsibilities_path
    end

    private

    def set_homes
      @homes = current_organisation.homes.accessible_by(current_ability)
    end

    def set_operators
      @operators = current_organisation.operators.accessible_by(current_ability)
    end

    def operator_responsibility_params
      params.require(:operator_responsibility).permit(:operator_id, :home_id, :ordinal_position, :responsibility,
                                                      :remarks)
    end
  end
end
