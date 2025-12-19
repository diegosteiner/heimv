# frozen_string_literal: true

module Public
  class BookingsController < BaseController
    before_action :set_booking, only: %i[show edit update]
    respond_to :html

    def show
      respond_with :public, @booking
    end

    def new
      @booking = preparation_service.prepare_new(create_params)
      process_booking_question_responses

      respond_with :public, @booking
    end

    def edit
      @booking.committed_request ||= @booking.agent_booking&.committed_request if @booking.agent_booking.present?
      process_booking_question_responses

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
      write_booking_log
      respond_with :public, @booking, location: -> { public_booking_path(@booking.token) }
    end

    private

    def set_booking
      @booking = current_organisation.bookings.find_by!(token: params[:id], concluded: false)
    end

    def write_booking_log
      Booking::Log.log(@booking, trigger: :tenant, user: current_user)
    end

    def process_booking_question_responses
      responses_params = params[:booking]&.permit(booking_question_responses_attributes: %i[booking_question_id value])
                                         &.fetch(:booking_question_responses_attributes, nil)
      @booking.booking_question_responses = BookingQuestionResponse.process(@booking, responses_params, role: :tenant)
    end

    def preparation_service
      @preparation_service ||= BookingPreparationService.new(current_organisation)
    end

    def create_params
      BookingParams::Create.new(params[:booking] || params)
    end

    def update_params
      BookingParams::Update.new(params[:booking])
    end
  end
end
