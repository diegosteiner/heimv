module Manage
  class BookingAgentsController < BaseController
    load_and_authorize_resource :booking_agent

    before_action { breadcrumbs.add(BookingAgent.model_name.human(count: :other), manage_booking_agents_path) }
    before_action(only: :new) { breadcrumbs.add(t(:new)) }
    before_action(only: %i[show edit]) do
      breadcrumbs.add(@booking_agent.to_s, manage_booking_agent_path(@booking_agent))
    end
    before_action(only: :edit) { breadcrumbs.add(t(:edit)) }

    def index
      respond_with :manage, @booking_agents
    end

    def show
      respond_with :manage, @booking_agent
    end

    def edit
      respond_with :manage, @booking_agent
    end

    def create
      @booking_agent.save
      respond_with :manage, @booking_agent
    end

    def update
      @booking_agent.update(booking_agent_params)
      respond_with :manage, @booking_agent
    end

    def destroy
      @booking_agent.destroy
      respond_with :manage, @booking_agent, location: manage_booking_agents_path
    end

    private

    def booking_agent_params
      Params::Manage::BookingAgentParams.new.permit(params)
    end
  end
end
