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
    ical_events = occupancies.flat_map do |occupancy|
      include_tenant_details ? occupancy_to_ical_with_tenant_details(occupancy) : occupancy_to_ical(occupancy)
    end
    ical_events.each { |occupancy| ical.add_event(occupancy) }
    ical.to_ical
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def occupancy_to_ical(occupancy)
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
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def occupancy_to_ical_with_tenant_details(occupancy)
    ical_event = occupancy_to_ical(occupancy)
    details = booking_details(occupancy.booking)
    return ical_event if details.blank?

    ical_event.summary = details[:summary]
    ical_event.description = format_lines(details.values, occupancy.remarks.presence)
    ical_event.attendee = icalendar_address(details[:tenant_contact])
    ical_event
  end

  def icalendar_address(address)
    Icalendar::Values::CalAddress.new(format_lines(address))
  end

  def icalendar_datetime(datetime)
    Icalendar::Values::DateTime.new(datetime.utc.strftime(Icalendar::Values::DateTime::FORMAT))
  end

  def booking_details(booking)
    booking&.instance_eval do
      {
        summary: "#{ref}: #{tenant_organisation || tenant&.name}".strip,
        purpose: "#{purpose_description} (#{category})",
        contact: [tenant_organisation, tenant&.contact_lines]
      }
    end
  end

  def format_lines(*lines)
    Array.wrap(lines).flatten.compact_blank.join("\n")
  end
end
