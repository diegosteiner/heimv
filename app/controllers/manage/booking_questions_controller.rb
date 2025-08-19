# frozen_string_literal: true

module Manage
  class BookingQuestionsController < BaseController
    load_and_authorize_resource :booking_question

    def index
      @booking_questions = @booking_questions.where(organisation: current_organisation).ordered
      respond_with :manage, @booking_questions
    end

    def new
      booking_question_to_clone = current_organisation.booking_questions.find(params[:clone]) if params[:clone]
      @booking_question = booking_question_to_clone.dup if booking_question_to_clone.present?
      respond_with :manage, @booking_question
    end

    def edit
      respond_with :manage, @booking_question
    end

    def create
      @booking_question.update(organisation: current_organisation)
      respond_with :manage, @booking_question, location: -> { edit_manage_booking_question_path(@booking_question) }
    end

    def update
      @booking_question.update(booking_question_params)
      respond_with :manage, @booking_question, location: -> { edit_manage_booking_question_path(@booking_question) }
    end

    def destroy
      # @booking_question.discarded? ? @booking_question.destroy : @booking_question.discard!
      @booking_question.destroy
      respond_with :manage, @booking_question, location: -> { manage_booking_questions_path }
    end

    private

    def booking_question_params
      BookingQuestionParams.new(params.require(:booking_question)).permitted
    end
  end
end
