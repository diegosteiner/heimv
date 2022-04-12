# frozen_string_literal: true

class OccupancyCalendar
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization

  attribute :home
  attribute :window_from, default: -> { Time.zone.today.beginning_of_day }
  attribute :window_to

  def initialize(attributes)
    super(attributes)
    self.window_to ||= home.settings.booking_window.from_now
  end

  def occupancies
    home.occupancies.blocking.at(from: window_from, to: window_to).includes(booking: [:deadline])
  end
end
