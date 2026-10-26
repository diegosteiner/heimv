# frozen_string_literal: true

class SharpenReservedOccupancyType < ActiveRecord::Migration[8.1]
  def change
    up_only do
      migrate_occupancy_visibility
      migrate_internal_occupancy_type
    end
  end

  def migrate_occupancy_visibility
    default_visibility = OrganisationSettings.new.public_occupancy_visibility.map(&:to_s)
    Organisation.find_each do |organisation|
      visibility = Array.wrap(organisation.settings.public_occupancy_visibility).map(&:to_s)
      organisation.settings.public_occupancy_visibility = if visibility.present? && visibility != default_visibility
                                                            visibility - %w[reserved internal]
                                                          end
      organisation.save!
    end
  end

  def migrate_internal_occupancy_type
    Organisation.find_each do |organisation|
      occupancies = Occupancy.where(conflict_type: 5, occupiable_id: organisation.occupiable_ids)
      next unless occupancies.exists?

      calendar_label = organisation.calendar_labels.create!(color: '#e85f5f', legend: true,
                                                            title_i18n: { de: 'intern', fr: 'interne',
                                                                          it: 'interna', en: 'internal' })
      occupancies.update_all(conflict_type: :occupied, calendar_label_id: calendar_label.id) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
