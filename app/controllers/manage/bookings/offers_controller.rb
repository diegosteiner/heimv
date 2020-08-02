# frozen_string_literal: true

module Manage
  module Bookings
    class OffersController < BaseController
      load_and_authorize_resource :booking
      load_and_authorize_resource :offer, through: :booking

      def index
        respond_with :manage, @offers
      end

      def new
        @offer.valid_from = Time.zone.now
        @offer.text = MarkdownTemplate[:offer_text].interpolate('booking' => @booking)
        respond_with :manage, @booking, @offer
      end

      def show
        respond_to do |format|
          # format.html
          format.pdf do
            reditect_to url_for(@offer.pdf)
          end
        end
      end

      def edit
        respond_with :manage, @offer
      end

      def create
        @offer.save
        respond_with :manage, @offer, location: manage_booking_offers_path(@booking)
      end

      def update
        @offer.update(offer_params)
        respond_with :manage, @offer, location: manage_booking_offers_path(@booking)
      end

      def destroy
        @offer.destroy
        respond_with :manage, @offer, location: manage_booking_offers_path(@booking)
      end

      private

      def offer_params
        OfferParams.new(params.require(:offer))
      end
    end
  end
end
