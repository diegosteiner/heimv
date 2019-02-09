module Public
  class BookingsController < BaseController
    load_and_authorize_resource :booking
    # before_action :initialize_view_model

    def new
      @booking.assign_attributes(booking_params) if booking_params
      unless @booking.occupancy
        @booking.build_occupancy(
          begins_at_time: '11:00',
          ends_at_time: '17:00'
        )
      end
      respond_with :public, @booking
    end

    def edit
      respond_with :public, @booking
    end

    def create
      @booking.save(context: :public_create)
      respond_with :public, @booking, location: root_path
    end

    def update
      if @booking.editable?
        @booking.assign_attributes(update_params)
        @booking.save(context: :public_update)
        @organisation.booking_strategy::BookingAction.new(@booking).call(booking_action) if booking_action
      else
        @booking.errors.add(:base, :invalid)
      end
      respond_with :public, @booking, location: edit_public_booking_path
    end

    private

    def booking_params
      BookingParams::Create.permit(params[:booking])
    end

    def booking_action
      params[:booking_action]
    end

    def update_params
      BookingParams::Update.permit(params[:booking]) || {}
    end
  end
end
