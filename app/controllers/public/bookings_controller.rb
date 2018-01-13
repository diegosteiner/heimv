module Public
  class BookingsController < BaseController
    load_resource :booking, find_by: :public_id

    def new
      @booking.build_occupancy
      @booking.build_customer
      respond_with @booking
    end

    def edit
      respond_with @booking
    end

    def create
      @booking.save
      respond_with @booking
    end

    def update
      @booking.update(update_params)
      respond_with @booking, location: edit_public_booking_path(@booking.public_id)
    end

    private

    def create_params
      Params::Public::BookingParamsService.new.call(params, true)
    end

    def update_params
      Params::Public::BookingParamsService.new.call(params, false)
    end
  end
end
