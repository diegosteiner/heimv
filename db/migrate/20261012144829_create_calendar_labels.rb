# frozen_string_literal: true

class CreateCalendarLabels < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_labels do |t|
      t.belongs_to :organisation
      t.jsonb :title_i18n, default: {}, null: false
      t.jsonb :description_i18n, default: {}, null: false
      t.string :color, null: false
      t.integer :conflict_type_default, null: true
      t.belongs_to :booking_categories, :booking_category_default,
                   foreign_key: { to_table: :booking_categories }, null: true
      t.datetime :discarded_at, null: true
      t.boolean :legend, null: false, default: true

      t.timestamps
    end
    add_index :calendar_labels, %i[organisation_id conflict_type_default booking_category_default_id], unique: true
    add_reference :occupancies, :calendar_label, foreign_key: true
    add_reference :bookings, :calendar_label, foreign_key: true

    change_column_null :bookings, :home_id, false

    up_only do
      migrate_conflict_type_default
      migrate_occupancy_occupancy_colors
      migrate_booking_occupancy_colors
    end
  end

  def migrate_conflict_type_default
    Organisation.find_each do |organisation|
      settings = JSON.parse(organisation.settings_before_type_cast)
      colors = {
        pending: settings['tentative_occupancy_color'],
        tentative: settings[''],
        occupied: settings['occupied_occupancy_color'],
        closed: settings['closed_occupancy_color']
      }
      CalendarLabel.prepare_default(organisation, colors:).each(&:save!)
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
        .each do
        next if it.blank?

        CalendarLabel.find_or_create_by!(organisation:, color: it, title_i18n: { de: 'Intern' }, legend: false)
      end

      organisation.calendar_labels.reload.find_each do |calendar_label|
        Occupancy.joins(:occupiable)
                 .where(occupiables: { organisation_id: organisation.id }, color: calendar_label.color)
                 .update_all(calendar_label_id: calendar_label.id, color: nil) # rubocop:disable Rails/SkipsModelValidations
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
                  .each do
                    next if it.blank?

                    CalendarLabel.find_or_create_by!(organisation:, color: it, title_i18n: { de: 'Intern' },
                                                     legend: false)
                  end

      organisation.calendar_labels.reload.find_each do |calendar_label|
        organisation.bookings.where(occupancy_color: calendar_label.color)
                    .update_all(calendar_label_id: calendar_label.id, occupancy_color: nil) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
