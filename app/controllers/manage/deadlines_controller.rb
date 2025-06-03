# frozen_string_literal: true

module Manage
  class DeadlinesController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :deadline, through: :booking, singleton: true

    def edit
      @deadline ||= @booking.build_deadline
      respond_with :manage, @deadline
    end

    def update
      @booking.create_deadline(**deadline_params) && booking.touch # rubocop:disable Rails/SkipsModelValidations
      respond_with :manage, @booking, location: manage_booking_path(@booking)
    end

    private

    def deadline_params
      params.expect(deadline: %i[at armed postponable_for remarks])
    end
  end
end
