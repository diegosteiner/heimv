# frozen_string_literal: true

module Manage
  class OperatorResponsibilitiesController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :operator_responsibility, through: :booking, shallow: true
    before_action :set_operators

    def index
      @operator_responsibilities = @operator_responsibilities.ordered.where(organisation: current_organisation,
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
      @operator_responsibility.assign_attributes(organisation: current_organisation, booking: @booking)
      @operator_responsibility.update(operator_responsibility_params)
      respond_with :manage, @operator_responsibility, location: -> { return_to_path }
    end

    def assign
      responsibility = operator_responsibility_params[:responsibility]
      return if @booking.blank? || responsibility.blank?

      @operator_responsibility = @booking.operator_responsibilities
                                         .find_or_initialize_by(organisation: current_organisation, responsibility:)
      @operator_responsibility.assign_attributes(operator_responsibility_params)
      if @operator_responsibility.operator.blank?
        @operator_responsibility.destroy unless @operator_responsibility.new_record?
      else
        @operator_responsibility.save
      end
      # respond_with :manage, @operator_responsibility
    end

    def update
      @booking ||= @operator_responsibility.booking
      @operator_responsibility.update(operator_responsibility_params)
      respond_with :manage, @operator_responsibility, location: -> { return_to_path }
    end

    def destroy
      @booking ||= @operator_responsibility.booking
      @operator_responsibility.destroy
      respond_with :manage, @operator_responsibility, location: -> { return_to_path }
    end

    private

    def set_operators
      @operators = current_organisation.operators.accessible_by(current_ability)
    end

    def return_to_path
      if (booking = @booking || @operator_responsibility&.booking)
        return manage_booking_operator_responsibilities_path(booking)
      end

      edit_manage_operator_responsibility_path(@operator_responsibility)
    end

    def operator_responsibility_params
      params.expect(operator_responsibility: %i[operator_id booking_id ordinal_position
                                                responsibility remarks assigning_conditions])
    end
  end
end
