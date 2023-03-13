# frozen_string_literal: true

module Public
  class AgentBookingsController < BaseController
    load_and_authorize_resource :agent_booking, except: %i[show edit update]
    before_action :set_agent_booking, only: %i[show edit update]

    def show
      redirect_to edit_public_agent_booking_path(@agent_booking.token || @agent_booking.to_param)
    end

    def new
      @agent_booking = AgentBooking.new(organisation: current_organisation)
      @agent_booking.assign_attributes(agent_booking_params)
      @agent_booking.booking.assign_attributes(booking_params) if booking_params.present?
      @agent_booking.booking.ends_at ||= @agent_booking.booking.begins_at
      respond_with :public, @agent_booking
    end

    def edit
      respond_with :public, @agent_booking
    end

    def create
      @agent_booking.assign_attributes(agent_booking_params.merge(organisation: current_organisation))

      if @agent_booking.save(context: :agent_booking)
        respond_with :public, @agent_booking, location: edit_public_agent_booking_path(@agent_booking.token)
      else
        render 'new'
      end
    end

    def update
      begin
        @agent_booking.assign_attributes(agent_booking_params)
      rescue ActiveRecord::RecordInvalid
        # See https://github.com/rails/rails/issues/17368
      end
      BookingActions::Public.all[booking_action]&.call(booking: @agent_booking.booking) if booking_action
      @agent_booking.save(context: :agent_booking)
      respond_with :public, @agent_booking, location: edit_public_agent_booking_path(@agent_booking.token)
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

    def booking_params
      BookingParams::Create.new(params[:booking]).permitted
    end
  end
end
