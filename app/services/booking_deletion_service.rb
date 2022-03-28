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
    booking.usages.destroy_all
    booking.booking_copy_tarifs.destroy_all
    booking.contracts.destroy_all
    booking.invoices.destroy_all
    booking.payments.destroy_all
    booking.notifications.destroy_all
    booking.booking_transitions.destroy_all
  end
end
