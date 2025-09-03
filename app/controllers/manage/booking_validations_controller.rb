# frozen_string_literal: true

module Manage
  class BookingValidationsController < BaseController
    load_and_authorize_resource :booking_validation

    def index
      @booking_validations = @booking_validations.where(organisation: current_organisation).ordered
      respond_with :manage, @booking_validations
    end

    def new
      booking_validation_to_clone = current_organisation.booking_validations.find(params[:clone]) if params[:clone]
      @booking_validation = booking_validation_to_clone.dup if booking_validation_to_clone.present?
      respond_with :manage, @booking_validation
    end

    def edit
      respond_with :manage, @booking_validation
    end

    def create
      @booking_validation.update(organisation: current_organisation)
      respond_with :manage, @booking_validation, location: lambda {
        edit_manage_booking_validation_path(@booking_validation)
      }
    end

    def update
      @booking_validation.update(booking_validation_params)
      respond_with :manage, @booking_validation, location: lambda {
        edit_manage_booking_validation_path(@booking_validation)
      }
    end

    def destroy
      # @booking_validation.discarded? ? @booking_validation.destroy : @booking_validation.discard!
      @booking_validation.destroy
      respond_with :manage, @booking_validation, location: -> { manage_booking_validations_path }
    end

    private

    def booking_validation_params
      BookingValidationParams.new(params.require(:booking_validation)).permitted
    end
  end
end
