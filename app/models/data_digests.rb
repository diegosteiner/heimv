# frozen_string_literal: true

module DataDigests
  TYPES = {
    booking: DataDigests::Booking,
    tenant: DataDigests::Tenant,
    tarif: DataDigests::Tarif,
    payment: DataDigests::Payment,
    parahotelerie_statistics: DataDigests::ParahotelerieStatistics,
    meter_reading_period: DataDigests::MeterReadingPeriod,
    home_booking_plan: DataDigests::HomeBookingPlan
  }.freeze
end
