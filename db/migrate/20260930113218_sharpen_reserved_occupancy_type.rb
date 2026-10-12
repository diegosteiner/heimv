# frozen_string_literal: true

class SharpenReservedOccupancyType < ActiveRecord::Migration[8.1]
  def change
    up_only do
      default_visibility = OrganisationSettings.new.public_occupancy_visibility.map(&:to_s)
      Organisation.find_each do |organisation|
        visibility = Array.wrap(organisation.settings.public_occupancy_visibility).map(&:to_s)
        organisation.settings.public_occupancy_visibility = if visibility.present? && visibility != default_visibility
                                                              visibility - %w[reserved internal]
                                                            end
        organisation.save!
      end
    end
  end
end
