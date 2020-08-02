# frozen_string_literal: true

class IcalService
  def generate_from_occupancy; end

  def generate_from_occupancies(occupancies)
    ical = Icalendar::Calendar.new
    ical_events = occupancies.map { |occupancy| generate_from_occupany(occupancy) }.flatten
    ical_events.each { |occupancy| ical.add_event(occupancy) }
    ical.to_ical
  end

  def generate_from_occupany(occupancy)
    Icalendar::Event.new.tap do |ical_event|
      ical_event.dtstart = formatted_datetime(occupancy.begins_at)
      ical_event.dtend = formatted_datetime(occupancy.ends_at)
      ical_event.summary = occupancy.booking.ref
      ical_event.location = occupancy.home.to_s
      # ical_event.contact = event.contact && event.contact.to_s
    end
  end

  def formatted_datetime(datetime)
    Icalendar::Values::DateTime.new(datetime.strftime(Icalendar::Values::DateTime::FORMAT))
  end
end
