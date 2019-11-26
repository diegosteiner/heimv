module Public
  class AgentBookingsController < BaseController
    load_and_authorize_resource :agent_booking

    def new
      @agent_booking.build_booking.tap do |booking|
        booking.organisation = current_organisation
        booking.build_occupancy unless booking.occupancy
        booking.occupancy.ends_at ||= booking.occupancy.begins_at
      end
      respond_with :public, @agent_booking
    end

    def create
      @agent_booking.booking.tap do |booking|
        booking.organisation = current_organisation
        booking.organisation = current_organisation
        booking.messages_enabled = true
        booking.agent_booking = @agent_booking
      end
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
      public_actions[booking_action]&.call(booking: @agent_booking.booking) if booking_action
      respond_with :public, @agent_booking, location: edit_public_agent_booking_path
    end

    private

    def public_actions
      current_organisation.booking_strategy.public_actions
    end

    def booking_action
      params[:booking_action]
    end

    def agent_booking_params
      AgentBookingParams.new(params[:agent_booking])
    end
  end
end
