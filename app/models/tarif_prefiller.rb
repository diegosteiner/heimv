# frozen_string_literal: true

class TarifPrefiller
  PREFILL_METHODS = {
    flat: ->(_booking) { 1 },
    nights: ->(booking) { booking.occupancy.nights },
    headcount_nights: ->(booking) { booking.occupancy.nights * (booking.approximate_headcount || 0) },
    headcount: ->(booking) { booking.approximate_headcount || 0 }
  }.with_indifferent_access.freeze

  def alleged_units(usage)
    PREFILL_METHODS[usage.tarif.prefill_usage_method]&.call(usage.booking)
  end
end
