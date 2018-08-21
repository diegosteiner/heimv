class UsageCalculator < ApplicationRecord
  DISTINCTION_REGEX = /\A\w*\z/

  belongs_to :home, inverse_of: :usage_calculators
  has_many :tarif_usage_calculators, dependent: :destroy, inverse_of: :usage_calculator
  has_many :tarifs, through: :tarif_usage_calculators

  accepts_nested_attributes_for :tarif_usage_calculators

  def calculate(booking, usages = booking.usages)
    tarif_usage_calculators.map do |tuc|
      usages.to_a.find { |u| u.of_tarif?(tuc.tarif) }.tap do |usage|
        next unless usage
        select_usage(usage, tuc.distinction) if tuc.perform_select
        calculate_usage(usage, tuc.distinction) if tuc.perform_calculate && usage.apply
      end
    end
  end

  def self.types
    %w[UsageCalculators::BookingNights UsageCalculators::BookingApproximateHeadcountPerNight
       UsageCalculators::BookingOvernightStays UsageCalculators::BookingOvernightStays]
  end

  def select_usage(_usage, _distinction); end

  def calculate_usage(_usage, _distinction); end
end
