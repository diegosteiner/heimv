# frozen_string_literal: true

class BookingDeletionService
  def initialize(organisation)
    @organisation = organisation
  end

  def delete!(booking)
    return unless booking.organisation == @organisation

    booking.notifications_enabled = false
    delete_dependent!(booking)
    booking.destroy!
  end

  def delete_all!
    Booking.transaction do
      @organisation.bookings.find_each do |booking|
        delete!(booking)
      end
    end
  end

  private

  def delete_dependent!(booking)
    booking.deadline&.destroy
    booking.agent_booking&.destroy
    dependent_associations = [booking.logs, booking.usages, booking.contracts, booking.invoices,
                              booking.payments, booking.notifications, booking.state_transitions]

    dependent_associations.each(&:destroy_all)
    dependent_associations.each(&:reload)
    dependent_associations.each(&:delete_all)
  end
end
