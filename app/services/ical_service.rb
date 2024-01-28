# frozen_string_literal: true

require 'icalendar/tzinfo'

class IcalService
  STATUS_MAP = {
    free: nil,
    tentative: 'TENTATIVE',
    occupied: 'CONFIRMED',
    closed: 'CONFIRMED'
  }.freeze

  def occupancies_to_ical(occupancies, include_tenant_details: false)
    ical = Icalendar::Calendar.new
    ical_events = occupancies.flat_map { |occupancy| occupancy_to_ical(occupancy, include_tenant_details:) }
    ical_events.each { |occupancy| ical.add_event(occupancy) }
    timezone = TZInfo::Timezone.get Time.zone.tzinfo.identifier
    ical.add_timezone timezone.ical_timezone Time.zone.now
    ical.to_ical
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def occupancy_to_ical(occupancy, include_tenant_details: false)
    Icalendar::Event.new.tap do |ical_event|
      ical_event.dtstart =       icalendar_datetime(occupancy.begins_at)
      ical_event.dtend =         icalendar_datetime(occupancy.ends_at)
      ical_event.created =       icalendar_datetime(occupancy.created_at)
      ical_event.last_modified = icalendar_datetime(occupancy.updated_at)
      ical_event.dtstamp =       icalendar_datetime(occupancy.updated_at)

      ical_event.uid =         occupancy.id
      ical_event.location =    occupancy.occupiable.to_s
      ical_event.summary =     occupancy.booking&.ref || occupancy.remarks
      ical_event.location =    occupancy.occupiable&.to_s
      ical_event.status =      STATUS_MAP.fetch(occupancy.occupancy_type, nil)
      ical_event.color =       occupancy.color
      ical_event.description = occupancy.remarks.presence

      next unless include_tenant_details

      ical_event.contact = icalendar_contact(occupancy)
      ical_event.attendee = icalendar_attendee(occupancy)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def icalendar_contact(occupancy)
    occupancy.booking&.instance_eval do
      [
        tenant_organisation, "#{purpose_description} (#{category})", tenant&.contact_lines
      ].flatten.compact_blank.join("\n")
    end
  end

  def icalendar_attendee(occupancy)
    Icalendar::Values::CalAddress.new
  end

  def icalendar_datetime(datetime)
    Icalendar::Values::DateTime.new(datetime, tzid: datetime.zone)
  end
end
