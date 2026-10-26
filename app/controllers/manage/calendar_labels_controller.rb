# frozen_string_literal: true

module Manage
  class CalendarLabelsController < BaseController
    load_and_authorize_resource :calendar_label

    def index
      @calendar_labels = @calendar_labels.where(organisation: current_organisation).ordered
      respond_with :manage, @calendar_labels
    end

    def edit
      respond_with :manage, @calendar_label
    end

    def create
      @calendar_label.organisation = current_organisation
      @calendar_label.save
      respond_with :manage, @calendar_label, location: -> { manage_calendar_labels_path }
    end

    def update
      @calendar_label.update(calendar_label_params)
      respond_with :manage, @calendar_label, location: -> { manage_calendar_labels_path }
    end

    def destroy
      @calendar_label.discarded? ? @calendar_label.destroy : @calendar_label.discard!
      respond_with :manage, @calendar_label, location: -> { manage_calendar_labels_path }
    end

    private

    def calendar_label_params
      locale_params = I18n.available_locales.map { |locale| ["title_#{locale}", "description_#{locale}"] }
      params.expect(calendar_label: [:color, :conflict_type_default, :booking_category_default_id, :legend,
                                     locale_params.flatten])
    end
  end
end
