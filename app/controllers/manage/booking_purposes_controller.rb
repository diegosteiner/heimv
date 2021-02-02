# frozen_string_literal: true

module Manage
  class BookingPurposesController < BaseController
    load_and_authorize_resource :booking_purpose

    def index
      @booking_purposes = @booking_purposes.where(organisation: current_organisation)
      respond_with :manage, @booking_purposes
    end

    def edit
      respond_with :manage, @booking_purpose
    end

    def create
      @booking_purpose.organisation = current_organisation
      @booking_purpose.save
      respond_with :manage, location: manage_booking_purposes_path
    end

    def update
      @booking_purpose.update(booking_purpose_params)
      respond_with :manage, location: manage_booking_purposes_path
    end

    def destroy
      @booking_purpose.destroy
      respond_with :manage, @booking_purpose, location: manage_booking_purposes_path
    end

    private

    def booking_purpose_params
      params.require(:booking_purpose).permit(:key,
                                              I18n.available_locales.map { |l| ["title_#{l}"] }.flatten)
    end
  end
end
