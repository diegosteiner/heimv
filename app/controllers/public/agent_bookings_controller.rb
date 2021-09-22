# frozen_string_literal: true

module Public
  class AgentBookingsController < BaseController
    load_and_authorize_resource :agent_booking
    before_action :set_agent_booking, only: %i[show edit update]

    def new
      @agent_booking = AgentBooking.new(organisation: current_organisation)
      @agent_booking.assign_attributes(agent_booking_params)
      @agent_booking.occupancy.ends_at ||= @agent_booking.occupancy.begins_at
      respond_with :public, @agent_booking
    end

    def create
      @agent_booking.assign_attributes(agent_booking_params.merge(organisation: current_organisation))
      @agent_booking.save_and_update_booking
      respond_with :public, @agent_booking
    end

    def show
      redirect_to edit_public_agent_booking_path(@agent_booking.token || @agent_booking.to_param)
    end

    def edit
      respond_with :public, @agent_booking
    end

    def update
      if @agent_booking.booking_agent_responsible?
        @agent_booking.assign_attributes(agent_booking_params)
        @agent_booking.save_and_update_booking
        BookingActions::Public.all[booking_action]&.call(booking: @agent_booking.booking) if booking_action
      end
      respond_with :public, @agent_booking, location: edit_public_agent_booking_path
    end

    private

    def set_agent_booking
      @agent_booking = AgentBooking.find_by(token: params[:id]) || AgentBooking.find(params[:id])
    end

    def booking_action
      params[:booking_action]
    end

    def agent_booking_params
      AgentBookingParams.new(params[:agent_booking]).permitted
    end
  end
end
