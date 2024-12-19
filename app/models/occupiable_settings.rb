# frozen_string_literal: true

class OccupiableSettings < Settings
  attribute :booking_margin, DurationType.new, default: 0
  attribute :accounting_cost_center_nr

  validates :booking_margin, numericality: { less_than_or_equal: 5.years, greater_than_or_equal: 0 }
end
