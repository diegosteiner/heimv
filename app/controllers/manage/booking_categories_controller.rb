# frozen_string_literal: true

module Manage
  class BookingCategoriesController < BaseController
    load_and_authorize_resource :booking_category

    def index
      @booking_categories = @booking_categories.where(organisation: current_organisation).ordered
      respond_with :manage, @booking_categories
    end

    def edit
      respond_with :manage, @booking_category
    end

    def create
      @booking_category.organisation = current_organisation
      @booking_category.save
      respond_with :manage, @booking_category, location: manage_booking_categories_path
    end

    def update
      @booking_category.update(booking_category_params)
      respond_with :manage, @booking_category, location: manage_booking_categories_path
    end

    def destroy
      @booking_category.discarded? ? @booking_category.destroy : @booking_category.discard!
      respond_with :manage, @booking_category, location: manage_booking_categories_path
    end

    private

    def booking_category_params
      locale_params = I18n.available_locales.map { |locale| ["title_#{locale}", "description_#{locale}"] }
      params.expect(booking_category: [:key, :ordinal_position, locale_params.flatten])
    end
  end
end
