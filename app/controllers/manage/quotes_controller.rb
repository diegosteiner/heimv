# frozen_string_literal: true

module Manage
  class QuotesController < BaseController
    load_and_authorize_resource :booking
    load_and_authorize_resource :quote, through: :booking, shallow: true

    def index
      @quotes = @quotes.where(booking: { organisation: current_organisation })
                       .includes(:organisation).ordered.with_attached_pdf
      @quotes = @quotes.where(booking: @booking) if @booking.present?
      @quotes = @quotes.kept if @booking.blank?

      respond_with :manage, @quotes
    end

    def show
      @booking = @quote.booking
      respond_to do |format|
        format.pdf do
          redirect_to url_for(@quote.pdf)
        end
      end
    end

    def new
      @quote = QuoteFactory.new(@booking).build(suggest_items: true, **quote_params)
      respond_with :manage, @booking, @quote
    end

    def edit
      @booking = @quote.booking
      respond_with :manage, @quote
    end

    def create
      @booking = @quote.booking
      @quote.save
      respond_with :manage, @quote, location: -> { manage_booking_quotes_path(@quote.booking) }
    end

    def update
      @booking = @quote.booking
      @quote.update(quote_params) unless @quote.discarded?
      respond_with :manage, @quote, location: -> { manage_booking_quotes_path(@quote.booking) }
    end

    def destroy
      @quote.discarded? || !@quote.sent? ? @quote.destroy : @quote.discard!
      respond_with :manage, @quote, location: -> { manage_booking_quotes_path(@quote.booking) }
    end

    private

    def quote_params
      QuoteParams.new(params[:quote]).permitted
    end
  end
end
