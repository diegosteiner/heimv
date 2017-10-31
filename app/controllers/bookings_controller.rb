class BookingsController < CrudController
  before_action :set_breadcrumbs

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
    super
    breadcrumbs.add Booking.model_name.human(count: :other), bookings_path

    case params[:action].to_sym
    when :new
      breadcrumbs.add t('new')
    when :show
      breadcrumbs.add @booking.to_s
    when :edit
      breadcrumbs.add @booking.to_s, booking_path(@booking)
      breadcrumbs.add t('edit')
    end
  end

  def booking_params
    params.require(:booking).permit(:home_id, :state, :customer_id,
                                    occupancy_attributes: %i[id begins_at ends_at],
                                    customer_attributes: %i[first_name last_name street_address zipcode city])
  end
end
