module Public
  class BookingsController < BaseController
    load_and_authorize_resource :booking, find_by: :public_id

    def new
      @booking.build_occupancy
      respond_with :public, @booking
    end

    def edit
      respond_with :public, @booking
    end

    def create
      @booking.transition_to = @booking.state_manager.prefered_transition
      @booking.save
      respond_with :public, @booking, location: root_path
    end

    def update
      @booking.update(update_params)
      respond_with :public, @booking, location: edit_public_booking_path(@booking.public_id)
    end

    private

    def create_params
      Rails.logger.debug "Called create_params with #{@booking.inspect}"
      Params::Public::BookingParams.new.call(params, @booking)
    end

    def update_params
      Params::Public::BookingParams.new.call(params, @booking)
    end
  end
end
