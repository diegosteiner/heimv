# frozen_string_literal: true

class BookingPreparationService
  def initialize(organisation)
    @organisation = organisation
  end

  def prepare_create(params)
    @organisation.bookings.new(params.reverse_merge({ notifications_enabled: true })).tap do |booking|
      booking.home ||= booking.occupiables.first&.home
      booking.locale = derive_locale(booking)
      booking.committed_request ||= !@organisation.booking_state_settings&.enable_provisional_request
    end
  end

  def prepare_new(params)
    prepare_create(params).tap do |booking|
      settings = @organisation.settings
      booking.occupiables = booking.home.occupiables if booking.home&.occupiables&.one?
      booking.begins_at = adjust_time(booking.begins_at, settings&.default_begins_at_time)
      booking.ends_at = adjust_time(booking.ends_at, settings&.default_ends_at_time)
    end
  end

  def derive_locale(booking)
    booking.locale.presence || (@organisation.locales & [I18n.locale]).first || @organisation.locale || I18n.locale
  end

  def adjust_time(value, default_time)
    return value.presence if value.blank? || value != value.midnight # || (10 < params[:begins_at]&.size)

    time_array = default_time&.split(':')
    time_hash = { hour: time_array&.first, minutes: time_array&.second }
    time_hash.present? ? value.change(time_hash) : value
  end
end
