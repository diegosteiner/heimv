# frozen_string_literal: true

class BookingPreparationService
  def initialize(organisation)
    @organisation = organisation
  end

  def prepare_create(params)
    @organisation.bookings.new(params).instance_exec do
      assign_attributes(notifications_enabled: true)
      self.home ||= occupiables.first&.home
      tenant&.locale ||= I18n.locale
      self
    end
  end

  def prepare_new(...)
    prepare_create(...).tap do |booking|
      booking.occupiables = booking.home.occupiables if booking.home&.occupiables&.count == 1
    end
  end
end
