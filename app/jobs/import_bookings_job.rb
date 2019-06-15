class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings: {}, tenants: {}, booking_tentants: )
    bookings.transform_values do |index, booking_data|
      Booking.new(booking_data)
    end

    tenants.transform_values do |index, tenant_data|
      Tenant.find_or_create_by(email: tenant_data[:email]) { |tenant| tenant.assign_attributes(tenant_data) }
    end

    booking_tentants.each do |
      # Rails.logger.info "Transitions of #{booking.ref}: #{transitions.join(' => ')}"
  end
end
