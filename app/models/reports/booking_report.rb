module Reports
class BookingReport < Report
  def filter
    @filter ||= Booking::Filter.new(filter_params)
  end

  def formats
    super + [:pdf]
  end

  def records
    @records ||= filter.reduce(Booking.all)
  end

  protected

  def generate_tabular_header
    [
      Booking.human_attribute_name(:ref), Home.model_name.human,
      Occupancy.human_attribute_name(:begins_at), Occupancy.human_attribute_name(:ends_at),
      Booking.human_attribute_name(:purpose)
    ]
  end

  def generate_tabular_footer
    []
  end

  def generate_tabular_row(booking)
    booking.instance_eval do
      [
        ref, home.name, I18n.l(occupancy.begins_at, format: :short), I18n.l(occupancy.begins_at, format: :short),
        Booking.human_enum(:purpose, purpose)
      ]
    end
  end
end
end
