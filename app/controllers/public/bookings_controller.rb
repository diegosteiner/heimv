module Public
  class BookingsController < BaseController
    load_and_authorize_resource :booking

    def new
      @booking.assign_attributes(booking_params) if booking_params
      @booking.build_occupancy unless @booking.occupancy
      @booking.occupancy.ends_at ||= @booking.occupancy.begins_at

      respond_with :public, @booking
    end

    def edit
      respond_with :public, @booking
    end

    def create
      @booking.messages_enabled = true
      @booking.save(context: :public_create)
      Rails.logger.debug @booking.id
      respond_with :public, @booking, location: root_path
    end

    def update
      if @booking.editable?
        @booking.assign_attributes(update_params)
        @booking.save(context: :public_update)
      end
      current_organisation.booking_strategy::Actions::Public[booking_action]&.new(@booking)&.call if booking_action
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
