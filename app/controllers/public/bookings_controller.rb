module Public
  class BookingsController < BaseController
    def new
      @booking = Booking.new(booking_params)
      @booking.build_occupancy unless @booking.occupancy
      @booking.occupancy.ends_at ||= @booking.occupancy.begins_at

      respond_with :public, @booking
    end

    def show
      @booking = Booking.find(params[:id])
      redirect_to edit_public_booking_path(@booking)
    end

    def edit
      @booking = Booking.find(params[:id])
      respond_with :public, @booking
    end

    def create
      @booking = Booking.new(booking_params)
      @booking.messages_enabled = true
      @booking.save(context: :public_create)
      respond_with :public, @booking, location: root_path
    end

    def update
      @booking = Booking.find(params[:id])
      if @booking.editable?
        @booking.assign_attributes(update_params)
        @booking.save(context: :public_update)
      end
      public_actions[booking_action]&.call(booking: @booking) if booking_action
      respond_with :public, @booking, location: edit_public_booking_path
    end

    private

    def public_actions
      current_organisation.booking_strategy.public_actions
    end

    def booking_params
      BookingParams::Create.new(params[:booking])
    end

    def booking_action
      params[:booking_action]
    end

    def update_params
      BookingParams::Update.new(params[:booking])
    end
  end
end
