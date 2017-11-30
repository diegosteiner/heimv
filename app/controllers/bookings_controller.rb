class BookingsController < CrudController
  def index
    respond_with @bookings
  end

  def show
    respond_with @booking
  end

  def new
    @booking.build_customer
    @booking.build_occupancy
    respond_with @booking
  end

  def edit; end

  def create
    @booking.build_customer
    @booking.build_occupancy
    @booking.update(booking_params)
    respond_with @booking
  end

  def update
    @booking.update(booking_params)
    respond_with @booking
  end

  def destroy
    @booking.destroy
    respond_with @booking, location: bookings_path
  end

  private

  def set_breadcrumbs
    set_crud_breadcrumbs(bookings_path, @booking)
  end

  def booking_params
    params.require(:booking).permit(:home_id, :state, :customer_id,
                                    occupancy_attributes: %i[id begins_at ends_at],
                                    customer_attributes: %i[first_name last_name street_address zipcode city])
  end
end
