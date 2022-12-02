# frozen_string_literal: true

module Manage
  class BookableExtrasController < BaseController
    load_and_authorize_resource :bookable_extra

    def index
      @bookable_extras = @bookable_extras.where(organisation: current_organisation)
      respond_with :manage, @bookable_extras
    end

    def new
      @bookable_extra.assign_attributes(bookable_extra_params) if bookable_extra_params
      respond_with :manage, @bookable_extra
    end

    def edit
      respond_with :manage, @bookable_extra
    end

    def create
      @bookable_extra.update(bookable_extra_params.merge(organisation: current_organisation))
      respond_with :manage, @bookable_extra, location: manage_bookable_extras_path
    end

    def update
      @bookable_extra.update(bookable_extra_params)
      respond_with :manage, @bookable_extra, location: manage_bookable_extras_path
    end

    def destroy
      @bookable_extra.destroy
      respond_with :manage, @bookable_extra, location: manage_bookable_extras_path
    end

    private

    def bookable_extra_params
      permitted_keys = I18n.available_locales.map { |locale| ["title_#{locale}", "description_#{locale}"] }.flatten
      params[:bookable_extra]&.permit(permitted_keys)
    end
  end
end
