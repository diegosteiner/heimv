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
      process_booking_question_responses
      respond_with :public, @agent_booking
    end

    def edit
      process_booking_question_responses

      respond_with :public, @agent_booking
    end

    def create
      @agent_booking.assign_attributes(agent_booking_params.merge(organisation: current_organisation))

      if @agent_booking.save(context: :agent_create)
        write_booking_log
        respond_with :public, @agent_booking, location: edit_public_agent_booking_path(@agent_booking.token)
      else
        render 'new'
      end
    end

    def update
      process_booking_question_responses
      begin
        @agent_booking.assign_attributes(agent_booking_params)
      rescue ActiveRecord::RecordInvalid
        # See https://github.com/rails/rails/issues/17368
      end
      @agent_booking.save(context: :agent_update)
      invoke_booking_action
      write_booking_log
      respond_with :public, @agent_booking, location: edit_public_agent_booking_path(@agent_booking.token)
    end

    private

    def process_booking_question_responses
      responses_params = params.dig(:agent_booking, :booking_attributes)
                               &.permit(booking_question_responses_attributes: %i[booking_question_id value])
                               &.fetch(:booking_question_responses_attributes, nil)
      @agent_booking.booking.booking_question_responses = BookingQuestionResponse.process(@agent_booking.booking,
                                                                                          responses_params,
                                                                                          role: :agent_booking)
    end

    def write_booking_log
      Booking::Log.log(@agent_booking.booking, trigger: :booking_agent, action: booking_action, user: current_user)
    end

    def set_agent_booking
      @agent_booking = AgentBooking.find_by(token: params[:id]) || AgentBooking.find(params[:id])
    end

    def booking_action
      @booking_action ||= @agent_booking.booking.booking_flow.booking_agent_action(params[:booking_action]&.to_sym)
      raise ActiveRecord::RecordNotFound if params[:booking_action].present? && @booking_action.blank?

      @booking_action
    end

    def invoke_booking_action
      result = booking_action&.invoke
      return @agent_booking.booking.errors.add(:base, :action_not_allowed) if booking_action && !result&.success

      @agent_booking.valid?
    end

    def agent_booking_params
      AgentBookingParams.new(params[:agent_booking]).permitted
    end

    def booking_params
      BookingParams::Create.new(params[:booking]).permitted
    end
  end
end
