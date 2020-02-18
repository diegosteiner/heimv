class OccupancyCalendar
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization

  attribute :home
  attribute :window_from, default: Time.zone.today.beginning_of_day
  attribute :window_to, default: 18.months.from_now.end_of_day

  def occupancies
    home.occupancies.blocking.at(from: window_from, to: window_to)
  end
end
