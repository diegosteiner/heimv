# frozen_string_literal: true

module Public
  class BookingsController < BaseController
    before_action :set_booking, only: %i[show edit update]

    def new
      @booking = Booking.new(create_params)
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
      @booking = Booking.new(create_params)
      @booking.notifications_enabled = true
      @booking.save(context: :public_create)
      respond_with :public, @booking, location: root_path
    end

    def update
      if @booking.editable?
        @booking.assign_attributes(update_params)
        @booking.save(context: :public_update)
      end
      call_booking_action
      respond_with :public, @booking, location: edit_public_booking_path(@booking.token)
    end

    private

    def set_booking
      @booking = Booking.find_by(token: params[:id]) || Booking.find(params[:id])
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
