# frozen_string_literal: true

class BookingPreparationService
  def initialize(organisation)
    @organisation = organisation
  end

  # rubocop:disable Metrics/AbcSize
  def prepare_create(params)
    @organisation.bookings.new(params.reverse_merge({ notifications_enabled: true })).tap do |booking|
      settings = @organisation.settings
      booking.begins_at = adjust_time(booking.begins_at, settings&.default_begins_at_time)
      booking.ends_at = adjust_time(booking.ends_at, settings&.default_ends_at_time)
      booking.home ||= booking.occupiables.first&.home
      booking.tenant&.locale ||= I18n.locale
    end
  end
  # rubocop:enable Metrics/AbcSize

  def prepare_new(...)
    prepare_create(...).tap do |booking|
      booking.occupiables = booking.home.occupiables if booking.home&.occupiables&.count == 1
    end
  end

  def adjust_time(value, default_time)
    return value.presence if value.blank? || value != value.midnight # || (10 < params[:begins_at]&.size)

    time_hash = OrganisationSettings.time_hash(default_time)
    time_hash.present? ? value.change(time_hash) : value
  end
end
