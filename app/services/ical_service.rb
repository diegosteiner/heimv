# frozen_string_literal: true

class IcalService
  def occupancies_to_ical(occupancies)
    ical = Icalendar::Calendar.new
    ical_events = occupancies.flat_map { |occupancy| occupancy_to_ical(occupancy) }
    ical_events.each { |occupancy| ical.add_event(occupancy) }
    ical.to_ical
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def occupancy_to_ical(occupancy)
    Icalendar::Event.new.tap do |ical_event|
      ical_event.dtstart =       formatted_datetime(occupancy.begins_at)
      ical_event.dtend =         formatted_datetime(occupancy.ends_at)
      ical_event.created =       formatted_datetime(occupancy.created_at)
      ical_event.last_modified = formatted_datetime(occupancy.updated_at)

      ical_event.location =    occupancy.occupiable.to_s
      ical_event.description = occupancy.remarks.presence
      ical_event.summary =     occupancy.booking&.ref
      ical_event.location =    occupancy.booking&.to_s
      ical_event.status =      occupancy.occupancy_type
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def formatted_datetime(datetime)
    Icalendar::Values::DateTime.new(datetime.utc.strftime(Icalendar::Values::DateTime::FORMAT))
  end
end
