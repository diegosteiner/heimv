# frozen_string_literal: true

module Tarifs
  class GroupMinimum < Tarif
    Tarif.register_subtype self

    def usages_in_group(usage)
      usage.booking.usages.joins(:tarif)
           .where(tarifs: { tarif_group: usage.tarif.tarif_group })
           .where.not(id: usage.id)
    end

    def group_price(usage)
      usages_in_group(usage).sum(&:price)
    end

    def minimum_price(usage)
      [minimum_prices(usage).values.max - group_price(usage), 0].max
    end

    def apply_usage_to_invoice?(usage, _invoice)
      usage.price.positive?
    end
  end
end
