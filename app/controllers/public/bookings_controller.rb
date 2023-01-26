# frozen_string_literal: true

module Public
  class BookingsController < BaseController
    before_action :set_booking, only: %i[show edit update]
    respond_to :html

    def show
      redirect_to edit_public_booking_path(@booking)
    end

    def new
      @booking = prepare_new_booking

      respond_with :public, @booking
    end

    def edit
      @booking.committed_request ||= @booking.agent_booking&.committed_request if @booking.agent_booking.present?
      respond_with :public, @booking
    end

    def create
      @booking = prepare_create_booking
      respond_to do |format|
        if @booking.save(context: :public_create)
          format.html { redirect_to organisation_path, notice: create_booking_notice }
          format.json { render json: { status: :created }, status: :created }
        else
          format.html { render :new }
          format.json { respond_with :public, @booking }
        end
      end
    end

    def update
      if @booking.editable?
        @booking.assign_attributes(update_params)
        @booking.save(context: :public_update)
      end
      call_booking_action
      Booking::Log.log(@booking, trigger: :tenant, action: booking_action, user: current_user)
      respond_with :public, @booking, location: edit_public_booking_path(@booking.token)
    end

    private

    def create_booking_notice
      t('flash.public.bookings.create.notice', email: @booking.email)
    end

    def set_booking
      @booking = current_organisation.bookings.find_by(token: params[:id]) ||
                 current_organisation.bookings.find(params[:id])
    end

    def booking_from_params
      current_organisation.bookings.new(create_params)
    end

    def prepare_create_booking
      current_organisation.bookings.new(create_params).instance_exec do
        assign_attributes(notifications_enabled: true)
        set_tenant && tenant.locale ||= I18n.locale
        self
      end
    end

    def prepare_new_booking
      prepare_create_booking.instance_exec do
        next self if begins_at.blank?

        self.begins_at += organisation.settings.begins_at_default_time if begins_at.seconds_since_midnight.zero?
        self.ends_at ||= begins_at + organisation.settings.ends_at_default_time
        self
      end
    end

    def call_booking_action
      booking_action&.call(booking: @booking)
    rescue BookingActions::Base::NotAllowed
      @booking.errors.add(:base, :action_not_allowed)
    end

    def booking_action
      BookingActions::Public.all[params[:booking_action]]
    end

    def create_params
      BookingParams::Create.new(params[:booking] || params)
    end

    def update_params
      BookingParams::Update.new(params[:booking])
    end
  end
end
