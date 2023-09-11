# frozen_string_literal: true

class IcalService
  def occupancies_to_ical(occupancies, include_tenant_details: false)
    ical = Icalendar::Calendar.new
    ical_events = occupancies.flat_map do |occupancy|
      occupancy_to_ical(occupancy, include_tenant_details: include_tenant_details)
    end
    ical_events.each { |occupancy| ical.add_event(occupancy) }
    ical.to_ical
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def occupancy_to_ical(occupancy, include_tenant_details: false)
    Icalendar::Event.new.tap do |ical_event|
      ical_event.dtstart =       formatted_datetime(occupancy.begins_at)
      ical_event.dtend =         formatted_datetime(occupancy.ends_at)
      ical_event.created =       formatted_datetime(occupancy.created_at)
      ical_event.last_modified = formatted_datetime(occupancy.updated_at)
      ical_event.dtstamp = formatted_datetime(occupancy.updated_at)
      ical_event.uid = occupancy.id

      ical_event.location =    occupancy.occupiable.to_s
      ical_event.summary =     occupancy.booking&.ref || occupancy.remarks
      ical_event.location =    occupancy.occupiable&.to_s
      ical_event.status =      occupancy.occupancy_type
      ical_event.description = (include_tenant_details && tenant_details_text(occupancy)) || occupancy.remarks.presence
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def tenant_details_text(occupancy)
    occupancy.booking&.instance_eval do
      [
        tenant_organisation, "#{purpose_description} (#{category})", tenant&.contact_lines
      ].flatten.compact_blank.join("\n")
    end
  end

  def formatted_datetime(datetime)
    Icalendar::Values::DateTime.new(datetime.utc.strftime(Icalendar::Values::DateTime::FORMAT))
  end
end
