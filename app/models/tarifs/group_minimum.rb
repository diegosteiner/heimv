# frozen_string_literal: true

module Tarifs
  class GroupMinimum < Tarif
    Tarif.register_subtype self

    def before_usage_validation(usage)
      usage.used_units = calculate_usage_delta(usage)
    end

    def minimum_usage_per_night
      0
    end

    def minimum_usage_total
      0
    end

    protected

    def usages_in_group(usage)
      usage.booking.usages.joins(:tarif).where(tarifs: { tarif_group: usage.tarif.tarif_group })
           .where.not(id: usage.id)
    end

    def calculate_price_delta(usage)
      group_price_total = usages_in_group(usage).sum(&:price)
      minimum_price = [
        (self[:minimum_usage_per_night] || 0) * usage.booking.nights,
        self[:minimum_usage_total] || 0
      ].max
      [minimum_price - group_price_total, 0].max
    end

    def calculate_usage_delta(usage)
      price_delta = calculate_price_delta(usage)
      return 0 unless price_delta.positive?

      price_delta / usage.price_per_unit
    end
  end
end
