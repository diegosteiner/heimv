# frozen_string_literal: true

module Manage
  class BookingsController < BaseController
    load_and_authorize_resource :booking
    before_action :set_filter, only: :index

    def index
      @bookings = @bookings.where(organisation: current_organisation)
      @bookings = @filter.apply(@bookings.with_default_includes.ordered, cached: true)
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
      @booking = preparation_service.prepare_new(booking_params)
      @booking.assign_attributes(organisation: current_organisation, transition_to: :provisional_request)
      @booking.booking_questions = BookingQuestion.applying_to_booking(@booking)

      respond_with :manage, @booking
    end

    def edit
      @booking.booking_questions = BookingQuestion.applying_to_booking(@booking)
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
      @booking.organisation = current_organisation
      responses = BookingQuestionResponse.process_nested_attributes(@booking, booking_question_responses_params,
                                                                    manage: true)
      @booking.booking_question_responses = responses unless responses.nil?
      @booking.save(context: :manage_create)
      Booking::Log.log(@booking, trigger: :manager, user: current_user)
      respond_with :manage, @booking
    end

    def update
      @booking.assign_attributes(booking_params)
      process_booking_question_responses
      @booking.save(context: :manage_update)
      redirect_to = call_booking_action
      write_booking_log
      respond_with :manage, @booking, location: redirect_to
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
      Booking::Log.log(@booking, trigger: :manager, action: booking_action, user: current_user)
    end

    def set_filter
      @filter = Booking::Filter.new(default_booking_filter_params.merge(booking_filter_params))
    end

    def process_booking_question_responses
      responses = BookingQuestionResponse.process_nested_attributes(@booking, booking_question_responses_params,
                                                                    manage: true)
      @booking.booking_question_responses = responses unless responses.nil?
    end

    def call_booking_action
      result = booking_action&.call(booking: @booking)
      instance_eval(&result.redirect_proc) if result&.redirect_proc.present?
    rescue BookingActions::Base::NotAllowed
      @booking.errors.add(:base, :action_not_allowed)
      nil
    end

    def booking_action
      BookingActions::Manage.all[params[:booking_action]]
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

    def default_booking_filter_params
      { 'current_booking_states' => BookingStates.displayed_by_default }
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
