# frozen_string_literal: true

module Manage
  class OccupancyLabelsController < BaseController
    load_and_authorize_resource :occupancy_label

    def index
      @occupancy_labels = @occupancy_labels.where(organisation: current_organisation).ordered
      respond_with :manage, @occupancy_labels
    end

    def edit
      respond_with :manage, @occupancy_label
    end

    def create
      @occupancy_label.organisation = current_organisation
      @occupancy_label.save
      respond_with :manage, @occupancy_label, location: -> { manage_occupancy_labels_path }
    end

    def update
      @occupancy_label.update(occupancy_label_params)
      respond_with :manage, @occupancy_label, location: -> { manage_occupancy_labels_path }
    end

    def destroy
      @occupancy_label.discarded? ? @occupancy_label.destroy : @occupancy_label.discard!
      respond_with :manage, @occupancy_label, location: -> { manage_occupancy_labels_path }
    end

    private

    def occupancy_label_params
      locale_params = I18n.available_locales.map { |locale| ["title_#{locale}", "description_#{locale}"] }
      params.expect(occupancy_label: [:color, :occupancy_status_default, locale_params.flatten])
    end
  end
end
