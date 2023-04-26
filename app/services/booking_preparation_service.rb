# frozen_string_literal: true

class BookingPreparationService
  def initialize(organisation)
    @organisation = organisation
  end

  def prepare_create(params)
    @organisation.bookings.new(params).instance_exec do
      assign_attributes(notifications_enabled: true)
      self.home ||= occupiables.first&.home
      set_tenant && tenant.locale ||= I18n.locale
      self
    end
  end

  # rubocop:disable Metrics/AbcSize
  def prepare_new(...)
    prepare_create(...).instance_exec do
      # self.occupiables = organisation.occupiables if occupancies.none?
      self.occupiables = home.occupiables if home&.occupiables&.count == 1
      next self if begins_at.blank?

      self.begins_at += organisation.settings.begins_at_default_time if begins_at.seconds_since_midnight.zero?
      self.ends_at ||= begins_at + organisation.settings.ends_at_default_time
      self
    end
  end
  # rubocop:enable Metrics/AbcSize
end
