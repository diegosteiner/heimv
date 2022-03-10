# frozen_string_literal: true

module TarifSelectors
  TYPES = {
    booking_nights: BookingNights,
    booking_aproximate_headcount_per_night: BookingApproximateHeadcountPerNight,
    always_apply: AlwaysApply,
    booking_overnight_stays: BookingOvernightStays,
    booking_purpose: BookingPurpose,
    bookable_extra: BookableExtra
  }.freeze
end
