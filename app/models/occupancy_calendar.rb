class OccupancyCalendar
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization

  attribute :home
  attribute :window_from, default: Time.zone.today.beginning_of_day
  attribute :window_to

  def occupancies
    window_to = self.window_to || home.organisation.booking_window.from_now
    home.occupancies.blocking.at(from: window_from, to: window_to)
  end
end
