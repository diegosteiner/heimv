# frozen_string_literal: true

module Manage
  class BookingAgentsController < BaseController
    load_and_authorize_resource :booking_agent

    def index
      @booking_agents = @booking_agents.where(organisation: current_organisation)
      respond_with :manage, @booking_agents
    end

    def show
      respond_with :manage, @booking_agent
    end

    def edit
      respond_with :manage, @booking_agent
    end

    def create
      @booking_agent.organisation = current_organisation
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
      BookingAgentParams.new(params.require(:booking_agent)).permitted
    end
  end
end
