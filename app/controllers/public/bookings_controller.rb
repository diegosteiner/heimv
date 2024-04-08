# frozen_string_literal: true

module Public
  class BookingsController < BaseController
    before_action :set_booking, only: %i[show edit update]
    respond_to :html

    def show
      redirect_to edit_public_booking_path(@booking)
    end

    def new
      @booking = preparation_service.prepare_new(create_params)
      @booking.booking_questions = BookingQuestion.applying_to_booking(@booking)

      respond_with :public, @booking
    end

    def edit
      @booking.committed_request ||= @booking.agent_booking&.committed_request if @booking.agent_booking.present?
      @booking.booking_questions = BookingQuestion.applying_to_booking(@booking)

      respond_with :public, @booking
    end

    def create
      @booking = preparation_service.prepare_create(create_params)
      respond_to do |format|
        if @booking.save(context: :public_create)
          format.html { render :confirm }
          format.json { render json: { status: :created }, status: :created }
        else
          format.html { render :new }
          format.json { respond_with :public, @booking }
        end
      end
    end

    def update
      process_booking_question_responses
      @booking.assign_attributes(update_params) if @booking.editable?
      @booking.save(context: :public_update)
      invoke_booking_action
      write_booking_log
      respond_with :public, @booking, location: edit_public_booking_path(@booking.token)
    end

    private

    def set_booking
      @booking = current_organisation.bookings.find_by(token: params[:id]) ||
                 current_organisation.bookings.find(params[:id])
    end

    def write_booking_log
      Booking::Log.log(@booking, trigger: :tenant, action: booking_action, user: current_user)
    end

    def booking_from_params
      current_organisation.bookings.new(create_params)
    end

    def process_booking_question_responses
      responses = BookingQuestionResponse.process_nested_attributes(@booking, booking_question_responses_params)
      @booking.booking_question_responses = responses unless responses.nil?
    end

    def preparation_service
      @preparation_service ||= BookingPreparationService.new(current_organisation)
    end

    def invoke_booking_action
      result = booking_action&.invoke
      @booking.errors.add(:base, :action_not_allowed) if booking_action && !result&.success
    end

    def booking_action
      BookingActions::Public.all[params[:booking_action]&.to_sym]&.new(@booking)
    end

    def create_params
      BookingParams::Create.new(params[:booking] || params)
    end

    def update_params
      BookingParams::Update.new(params[:booking])
    end

    def booking_question_responses_params
      params[:booking]&.permit(booking_question_responses_attributes: %i[booking_question_id value])
                      &.fetch(:booking_question_responses_attributes, nil)
    end
  end
end
