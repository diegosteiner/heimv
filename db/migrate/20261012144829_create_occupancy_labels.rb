# frozen_string_literal: true

class CreateOccupancyLabels < ActiveRecord::Migration[8.1]
  def change
    create_table :occupancy_labels do |t|
      t.belongs_to :organisation
      t.jsonb :title_i18n, default: {}, null: false
      t.jsonb :description_i18n, default: {}, null: false
      t.string :color, null: false
      t.integer :occupancy_status_default, null: true
      t.datetime :discarded_at, null: true

      t.timestamps
    end
    add_index :occupancy_labels, %i[organisation_id occupancy_status_default], unique: true
    add_reference :occupancies, :occupancy_label, foreign_key: true
    add_reference :bookings, :occupancy_label, foreign_key: true

    up_only do
      migrate_occupancy_status_default
      migrate_occupancy_occupancy_colors
      migrate_booking_occupancy_colors
    end
  end

  def migrate_occupancy_status_default
    Organisation.find_each do |organisation|
      OccupancyLabel.create_defaults(organisation, defaults: organisation.settings.try(:occupancy_colors) || {})
    end
  end

  def migrate_occupancy_occupancy_colors
    Organisation.find_each do |organisation|
      Occupancy
        .joins(:occupiable)
        .where(occupiables: { organisation_id: organisation.id }, ends_at: (Time.zone.now)..)
        .select(Occupancy.arel_table[:color])
        .group(Occupancy.arel_table[:color])
        .having(Occupancy.arel_table[:color].count.gt(1))
        .distinct
        .pluck(Occupancy.arel_table[:color])
        .each { OccupancyLabel.find_or_create_by!(organisation:, color: it) if it.present? }

      organisation.occupancy_labels.reload.find_each do |occupancy_label|
        Occupancy.joins(:occupiable)
                 .where(occupiables: { organisation_id: organisation.id }, color: occupancy_label.color)
                 .update_all(occupancy_label_id: occupancy_label.id, color: nil) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end

  def migrate_booking_occupancy_colors
    Organisation.find_each do |organisation|
      organisation.bookings
                  .where(ends_at: (Time.zone.now)..)
                  .select(Booking.arel_table[:occupancy_color])
                  .group(Booking.arel_table[:occupancy_color])
                  .having(Booking.arel_table[:occupancy_color].count.gt(1))
                  .distinct
                  .pluck(Booking.arel_table[:occupancy_color])
                  .each { OccupancyLabel.find_or_create_by(organisation:, color: it) if it.present? }

      organisation.occupancy_labels.reload.find_each do |occupancy_label|
        organisation.bookings.where(occupancy_color: occupancy_label.color)
                    .update_all(occupancy_label_id: occupancy_label.id, occupancy_color: nil) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
