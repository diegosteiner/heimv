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
    booking.logs.delete_all
    booking.usages.delete_all
    booking.contracts.delete_all
    booking.invoices.delete_all
    booking.payments.delete_all
    booking.notifications.delete_all
    booking.state_transitions.delete_all
  end
end
