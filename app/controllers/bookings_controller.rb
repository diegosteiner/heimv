class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @bookings = Booking.all
    authorize Booking
  end

  def show
    breadcrumbs.add @booking.to_s
  end

  def new
    authorize Booking
    breadcrumbs.add t('new')
    @booking = Booking.new
  end

  def edit
    breadcrumbs.add @booking.to_s, booking_path(@booking)
    breadcrumbs.add t('edit')
  end

  def create
    authorize Booking
    @booking = Booking.new(booking_params)

    if @booking.save
      redirect_to @booking, notice: t('actions.create.success', model_name: Booking.model_name.human)
    else
      render :new
    end
  end

  def update
    if @booking.update(booking_params)
      redirect_to @booking, notice: t('actions.update.success', model_name: Booking.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @booking.destroy
    redirect_to bookings_path, notice: t('actions.destroy.success', model_name: Booking.model_name.human)
  end

  private
    def set_booking
      @booking = Booking.find(params[:id])
      authorize @booking
    end

    def set_breadcrumbs
      super
      breadcrumbs.add Booking.model_name.human(count: :other), bookings_path
    end

    def booking_params
      params.require(:booking).permit(:occupancy_id, :home_id, :state, :customer_id)
    end
end
