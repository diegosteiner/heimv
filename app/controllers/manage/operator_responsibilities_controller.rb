# frozen_string_literal: true

module Manage
  class OperatorResponsibilitiesController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :operator_responsibility, through: :booking, shallow: true
    before_action :set_homes, :set_operators, only: %i[new create edit update]

    def index
      @operator_responsibilities = @operator_responsibilities.ordered
                                                             .where(organisation: current_organisation,
                                                                    booking: @booking)
      respond_with :manage, @operator_responsibilities
    end

    def new
      @operator_responsibility.booking = @booking
      respond_with :manage, @operator_responsibility
    end

    def edit
      @booking ||= @operator_responsibility.booking
      respond_with :manage, @operator_responsibility
    end

    def create
      @booking ||= @operator_responsibility.booking
      @operator_responsibility.assign_attributes(organisation: current_organisation,
                                                 home: @booking&.home, booking: @booking)
      @operator_responsibility.update(operator_responsibility_params)
      respond_with :manage, @operator_responsibility, location: return_to_path
    end

    def update
      @booking ||= @operator_responsibility.booking
      @operator_responsibility.update(operator_responsibility_params)
      respond_with :manage, @operator_responsibility, location: return_to_path
    end

    def destroy
      @booking ||= @operator_responsibility.booking
      @operator_responsibility.destroy
      respond_with :manage, @operator_responsibility, location: return_to_path
    end

    private

    def set_homes
      @homes = current_organisation.homes.accessible_by(current_ability)
    end

    def set_operators
      @operators = current_organisation.operators.accessible_by(current_ability)
    end

    def return_to_path
      return manage_operator_responsibilities_path if @operator_responsibility.booking.blank?

      manage_booking_operator_responsibilities_path(@operator_responsibility.booking)
    end

    def operator_responsibility_params
      params.require(:operator_responsibility).permit(:operator_id, :home_id, :booking_id,
                                                      :ordinal_position, :responsibility, :remarks)
    end
  end
end
