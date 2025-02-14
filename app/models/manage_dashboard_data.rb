# frozen_string_literal: true

class ManageDashboardData
  attr_reader :organisation

  def initialize(organisation)
    @organisation = organisation
  end

  def state_group_counts
    @state_counts = state_class_groups.transform_values do |state_class_group|
      organisation.bookings.where(booking_state_cache: state_class_group.map(&:to_sym)).count
    end
  end

  def open_invoices
    organisation.invoices.unpaid
  end

  def logs_since(since)
    Booking::Log.joins(:booking).where(booking: { organisation: })
                .where(Booking::Log.arel_table[:created_at].gteq(since))
                .where(trigger: %i[auto tenant])
  end

  def state_class_groups
    {
      open_bookings: [BookingStates::OpenRequest],
      definitive_bookings: [BookingStates::DefinitiveRequest],
      past_bookings: [BookingStates::Past],
      overdue_bookings: [BookingStates::OverdueRequest, BookingStates::Overdue],
      upcoming_bookings: [BookingStates::Upcoming, BookingStates::UpcomingSoon]
    }
  end
end
