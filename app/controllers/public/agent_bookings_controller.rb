module Public
  class AgentBookingsController < BaseController
    load_and_authorize_resource :agent_booking

    def new
      @agent_booking.build_booking
      @agent_booking.booking.build_occupancy
      respond_with :public, @agent_booking
    end

    def create
      @agent_booking.booking.messages_enabled = true
      @agent_booking.booking.agent_booking = @agent_booking
      @agent_booking.save
      respond_with :public, @agent_booking
    end

    def show
      redirect_to edit_public_agent_booking_path(@agent_booking)
    end

    def edit
      respond_with :public, @agent_booking
    end

    def update
      @agent_booking.update(agent_booking_params) if @agent_booking.booking.editable?
      Booking.strategy.public_actions[booking_action]&.call(@agent_booking.booking) if booking_action
      respond_with :public, @agent_booking, location: edit_public_agent_booking_path
    end

    private

    def booking_action
      params[:booking_action]
    end

    def agent_booking_params
      AgentBookingParams.permit(params[:agent_booking]) || {}
    end
  end
end
