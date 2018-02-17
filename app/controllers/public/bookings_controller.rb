module Public
  class BookingsController < BaseController
    load_and_authorize_resource :booking, find_by: :public_id
    before_action :initialize_view_model

    def new
      @booking.build_occupancy
      @booking.occupancy.begins_at = Time.zone.now
      @booking.occupancy.ends_at = @booking.occupancy.begins_at + 7.days
      respond_with :public, @booking
    end

    def edit
      respond_with :public, @booking
    end

    def create
      @booking.skip_exact_validation = true
      @booking.save
      respond_with :public, @booking, location: root_path
    end

    def update
      @booking.update(update_params)
      respond_with :public, @booking, location: edit_public_booking_path(@booking.public_id)
    end

    private

    def initialize_view_model
      @view_model = @booking.booking_strategy::ViewModel.new(@booking)
    end

    def create_params
      Params::Public::BookingParams.new.call(params, @booking)
    end

    def update_params
      Params::Public::BookingParams.new.call(params, @booking)
    end
  end
end
