# frozen_string_literal: true

module Manage
  class OrganisationOperatorsController < BaseController
    load_and_authorize_resource :organisation_operator
    before_action :set_homes, only: %i[new edit]
    before_action :set_operators, only: %i[new edit index]

    def index
      @organisation_operators = @organisation_operators.where(organisation: current_organisation)
      respond_with :manage, @organisation_operators
    end

    def show
      respond_with :manage, @organisation_operator
    end

    def new
      respond_with :manage, @organisation_operator
    end

    def edit
      respond_with :manage, @organisation_operator
    end

    def create
      @organisation_operator.organisation = current_organisation
      @organisation_operator.update(organisation_operator_params)
      respond_with :manage, @organisation_operator
    end

    def update
      @organisation_operator.update(organisation_operator_params)
      respond_with :manage, @organisation_operator, location: params[:return_path]
    end

    def destroy
      @organisation_operator.destroy
      respond_with :manage, @organisation_operator, location: manage_organisation_operators_path
    end

    private

    def set_homes 
      @homes = current_organisation.homes.accessible_by(current_ability)
    end

    def set_operators
      @operators = current_organisation.operators.accessible_by(current_ability)
    end

    def organisation_operator_params
      params.require(:organisation_operator).permit(:operator_id, :home_id, :ordinal, :responsibility, :remarks)
    end
  end
end
