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

      respond_with :public, @booking
    end

    def edit
      @booking.committed_request ||= @booking.agent_booking&.committed_request if @booking.agent_booking.present?
      respond_with :public, @booking
    end

    def create
      @booking = preparation_service.prepare_create(create_params)
      respond_to do |format|
        if @booking.save(context: :public_create)
          format.html { redirect_to organisation_path, notice: create_booking_notice }
          format.json { render json: { status: :created }, status: :created }
        else
          format.html { render :new }
          format.json { respond_with :public, @booking }
        end
      end
    end

    def update
      if @booking.editable?
        @booking.assign_attributes(update_params)
        @booking.save(context: :public_update)
      end
      call_booking_action
      Booking::Log.log(@booking, trigger: :tenant, action: booking_action, user: current_user)
      respond_with :public, @booking, location: edit_public_booking_path(@booking.token)
    end

    private

    def create_booking_notice
      t('flash.public.bookings.create.notice', email: @booking.email)
    end

    def set_booking
      @booking = current_organisation.bookings.find_by(token: params[:id]) ||
                 current_organisation.bookings.find(params[:id])
    end

    def booking_from_params
      current_organisation.bookings.new(create_params)
    end

    def preparation_service
      @preparation_service ||= BookingPreparationService.new(current_organisation)
    end

    def call_booking_action
      booking_action&.call(booking: @booking)
    rescue BookingActions::Base::NotAllowed
      @booking.errors.add(:base, :action_not_allowed)
    end

    def booking_action
      BookingActions::Public.all[params[:booking_action]]
    end

    def create_params
      BookingParams::Create.new(params[:booking] || params)
    end

    def update_params
      BookingParams::Update.new(params[:booking])
    end
  end
end
