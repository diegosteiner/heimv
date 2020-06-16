module Public
  class BookingsController < BaseController
    def new
      @booking = Booking.new(create_params)
      @booking.organisation = current_organisation
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
      @booking.committed_request = @booking.agent_booking&.committed_request
      respond_with :public, @booking
    end

    def create
      @booking = Booking.new(create_params)
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
      call_booking_action
      respond_with :public, @booking, location: edit_public_booking_path
    end

    private

    def call_booking_action
      booking_action&.call(booking: @booking)
    rescue BookingStrategy::Action::NotAllowed
      @booking.errors.add(:base, :action_not_allowed)
    end

    def booking_action
      current_organisation.booking_strategy.public_actions[params[:booking_action]]
    end

    def create_params
      BookingParams::Create.new(params[:booking] || params)
    end

    def update_params
      BookingParams::Update.new(params[:booking])
    end
  end
end
