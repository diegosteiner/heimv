class BookingsController < CrudController
  load_and_authorize_resource :booking
  load_and_authorize_resource :occupancy, through: :booking
  load_and_authorize_resource :customer, through: :booking

  before_action { breadcrumbs.add(Home.model_name.human(count: :other), bookings_path) }
  before_action(only: :new) { breadcrumbs.add(t('new')) }
  before_action(only: %i[show edit]) { breadcrumbs.add(@booking.to_s, booking_path(@booking)) }
  before_action(only: :edit) { breadcrumbs.add(t('edit')) }

  def index
    respond_with @bookings
  end

  def show
    respond_with @booking
  end

  def new
    @booking.build_occupancy
    @booking.build_customer
    respond_with @booking
  end

  def edit; end

  def create
    @booking.save
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

  def booking_params
    params.require(:booking).permit(:home_id, :state, :customer_id,
                                    occupancy_attributes: %i[begins_at ends_at],
                                    customer_attributes: %i[first_name last_name street_address zipcode city])
  end
end
