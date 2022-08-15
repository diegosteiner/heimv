# frozen_string_literal: true

module Public
  class BookingsController < BaseController
    before_action :set_booking, only: %i[show edit update]
    respond_to :html

    def new
      @booking = current_organisation.bookings.new(create_params)
      @booking.organisation = current_organisation
      @booking.build_occupancy unless @booking.occupancy
      @booking.occupancy.ends_at ||= @booking.occupancy.begins_at

      respond_with :public, @booking
    end

    def show
      redirect_to edit_public_booking_path(@booking)
    end

    def edit
      @booking.committed_request ||= @booking.agent_booking&.committed_request if @booking.agent_booking?
      respond_with :public, @booking
    end

    def create
      @booking = prepare_create_booking
      respond_to do |format|
        if @booking.save(context: :public_create) && @booking.transition_to
          format.html { redirect_to root_path, notice: create_booking_notice }
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
        @booking.save(context: :public_update) && @booking.transition_to
      end
      call_booking_action
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

    def prepare_create_booking
      current_organisation.bookings.new(create_params).tap do |booking|
        booking.assign_attributes(notifications_enabled: true)
        booking.set_tenant && booking.tenant.locale ||= I18n.locale
      end
    end

    def call_booking_action
      booking_action&.call(booking: @booking, current_user: current_user)
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
