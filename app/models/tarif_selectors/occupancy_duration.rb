# frozen_string_literal: true

# == Schema Information
#
# Table name: tarif_selectors
#
#  id          :bigint           not null, primary key
#  distinction :string
#  type        :string
#  veto        :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tarif_id    :bigint
#
# Indexes
#
#  index_tarif_selectors_on_tarif_id  (tarif_id)
#
# Foreign Keys
#
#  fk_rails_...  (tarif_id => tarifs.id)
#

module TarifSelectors
  class OccupancyDuration < NumericDistinction
    def self.distinction_regex
      /\A([><=])?(\d*)\s*([smhd]?)\z/
    end

    validates :distinction, format: { with: distinction_regex }, allow_blank: true

    def apply?(usage, presumable_usage = presumable_usage(usage))
      _match, operator, threshold_value, threshold_unit = *self.class.distinction_regex.match(distinction)
      threshold_usage = threshold_usage(threshold_value.to_i, threshold_unit)

      return if presumable_usage.blank?
      return presumable_usage < threshold_usage if operator == '<'
      return presumable_usage > threshold_usage if operator == '>'

      threshold_usage.blank? || presumable_usage == threshold_usage
    end

    def presumable_usage(usage)
      usage.booking.occupancy.duration
    end

    protected

    def threshold_usage(value, unit)
      return value.days if unit == 'd'
      return value.hours if unit == 'h'
      return value.minutes if unit == 'm'

      value.second
    end
  end
end
