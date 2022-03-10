# frozen_string_literal: true

module Manage
  class BookableExtrasController < BaseController
    load_and_authorize_resource :home
    load_and_authorize_resource :bookable_extra, through: :home, shallow: true

    def index
      @bookable_extras = @bookable_extras.where(organisation: current_organisation, home: @home)
      respond_with :manage, @bookable_extras
    end

    def new
      @bookable_extra.home = @home
      @bookable_extra.assign_attributes(bookable_extra_params) if bookable_extra_params
      respond_with :manage, @bookable_extra
    end

    def edit
      respond_with :manage, @bookable_extra
    end

    def create
      @bookable_extra.assign_attributes(organisation: current_organisation)
      @bookable_extra.update(bookable_extra_params)
      respond_with :manage, @bookable_extra, location: return_to_path
    end

    def update
      @bookable_extra.update(bookable_extra_params)
      respond_with :manage, @bookable_extra, location: return_to_path
    end

    def destroy
      @bookable_extra.destroy
      respond_with :manage, @bookable_extra, location: return_to_path
    end

    private

    def return_to_path
      return manage_home_bookable_extras_path(@bookable_extra.home) if @bookable_extra.home.present?

      manage_bookable_extras_path
    end

    def bookable_extra_params
      permitted_keys = I18n.available_locales.map { |locale| ["title_#{locale}", "description_#{locale}"] }.flatten
      params[:bookable_extra]&.permit(%i[home_id] + permitted_keys)
    end
  end
end
