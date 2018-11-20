module Public
  class BookingsController < BaseController
    load_and_authorize_resource :booking
    before_action :initialize_view_model

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
      # @booking.initiator = :tenant
      @booking.save(context: :public_create)
      respond_with :public, @booking, location: root_path
    end

    def update
      # @booking.initiator = :tenant
      @booking.assign_attributes(update_params)
      @booking.save(context: :public_update)
      respond_with :public, @booking, location: edit_public_booking_path
    end

    private

    def initialize_view_model
      @view_model = @booking.booking_strategy::ViewModel.new(@booking)
    end

    def booking_params
      BookingParams::Create.permit(params[:booking])
    end

    def update_params
      BookingParams::Update.permit(params.require(:booking))
    end
  end
end
