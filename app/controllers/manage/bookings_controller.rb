# frozen_string_literal: true

module Manage
  class BookingsController < BaseController
    load_and_authorize_resource :booking
    before_action :set_filter, only: :index

    def index
      @bookings = @bookings.where(organisation: current_organisation)
      @bookings = @filter.apply(@bookings.with_default_includes.ordered, cached: false)

      respond_with :manage, @bookings
    end

    def show
      respond_to do |format|
        format.html
        format.json { render json: BookingSerializer.render(@booking) }
      end
    end

    def calendar
      @occupiables = current_organisation.occupiables.occupiable.ordered
      respond_with :manage, @booking
    end

    def new
      transition_to = current_organisation.booking_state_settings.default_manage_transition_to_state
      @booking = preparation_service.prepare_new(booking_params)
      @booking.assign_attributes(organisation: current_organisation, transition_to:)
      process_booking_question_responses

      respond_with :manage, @booking
    end

    def edit
      process_booking_question_responses
    end

    def new_import
      @import = Import.new(organisation: current_organisation)

      render 'import'
    end

    def import
      @import = Import.new(booking_import_params.merge(organisation: current_organisation))

      if @import.valid?
        result = @import.result
        return redirect_to manage_bookings_path, notice: t('.import_success') if result.ok?
      end

      flash.now[:alert] = t('.import_error')
    end

    def create
      @booking.assign_attributes(booking_params)
      @booking.organisation = current_organisation
      process_booking_question_responses
      @booking.save(context: :manage_create)
      write_booking_log
      respond_with :manage, @booking
    end

    def update
      @booking.assign_attributes(booking_params)
      process_booking_question_responses
      @booking.save(context: :manage_update)
      write_booking_log
      respond_with :manage, @booking
    end

    def destroy
      deletion_service = BookingDeletionService.new(current_organisation)
      deletion_service.delete!(@booking)
      respond_with :manage, @booking, location: return_to_path(manage_bookings_path)
    end

    private

    def preparation_service
      @preparation_service ||= BookingPreparationService.new(current_organisation)
    end

    def write_booking_log
      Booking::Log.log(@booking, trigger: :manager, user: current_user)
    end

    def set_filter
      default_filter_params = {
        concluded: :inconcluded,
        current_booking_states: current_organisation.booking_flow_class.displayed_by_default
      }.with_indifferent_access

      @filter = Booking::Filter.new(default_filter_params.merge(booking_filter_params || {}))
    end

    def process_booking_question_responses
      responses_params = params[:booking]&.permit(booking_question_responses_attributes: %i[booking_question_id value])
                                         &.fetch(:booking_question_responses_attributes, nil)
      @booking.booking_question_responses = BookingQuestionResponse.process(@booking,
                                                                            responses_params,
                                                                            role: :manager)
    end

    def booking_params
      BookingParams.new(params[:booking]).permitted
    end

    def booking_filter_params
      Manage::BookingFilterParams.new(params[:filter]).permitted
    end

    def booking_import_params
      params[:manage_bookings_controller_import]&.permit(%i[home_id file headers initial_state]) || {}
    end

    def booking_question_responses_params
      params[:booking]&.permit(booking_question_responses_attributes: %i[booking_question_id value])
                      &.fetch(:booking_question_responses_attributes, nil)
    end

    class Import < Import::ApplicationImport
      attribute :home_id
      attribute :initial_state

      validates :home_id, presence: true

      def import!
        return unless valid?

        home = organisation.homes.find(home_id)
        headers = self.headers.presence&.split(/[,;]/) || true

        ::Import::Csv::BookingImporter.new(home, initial_state:, csv: { headers: })
                                      .parse_file(file)
      end
    end
  end
end
