# frozen_string_literal: true

module Manage
  class OperatorsController < BaseController
    load_and_authorize_resource :operator

    def index
      @operators = @operators.where(organisation: current_organisation)
      respond_with :manage, @operators
    end

    def show
      respond_with :manage, @operator
    end

    def new
      respond_with :manage, @operator
    end

    def edit
      respond_with :manage, @operator
    end

    def create
      @operator.organisation = current_organisation
      @operator.locale = current_organisation.locale
      @operator.update(operator_params)
      respond_with :manage, @operator, location: manage_operators_path
    end

    def update
      @operator.update(operator_params)
      respond_with :manage, @operator, location: manage_operators_path
    end

    def destroy
      @operator.destroy
      respond_with :manage, @operator, location: manage_operator_responsibilities_path
    end

    private

    def operator_params
      params.expect(operator: %i[name email contact_info locale])
    end
  end
end
