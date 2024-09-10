# frozen_string_literal: true

class ComparableDatetime < Data.define(:year, :month, :day, :weekday, :hour, :minute) # rubocop:disable Style/DataInheritance
  include Comparable

  # rubocop:disable Lint/MixedRegexpCaptureTypes:
  REGEX = /\A
            (?:(?<year>(\d{4}|\*))-(?<month>(\d{1,2}|\*))-(?<day>(\d{1,2}|\*)))?\s*
            (?:(W(?<weekday>(\d{1}|\*))))?\s*
            (?:(T(?<hour>(\d{1,2}|\*)):(?<minute>(\d{1,2}|\*))))?
          \z/ix
  # rubocop:enable Lint/MixedRegexpCaptureTypes:

  def self.from_date(value)
    # value = value.utc if value.respond_to?(:utc)
    new(year: value.year, month: value.month, day: value.mday, weekday: value.wday,
        hour: value.try(:hour), minute: value.try(:min))
  end

  def self.from_string(value)
    match_data = REGEX.match(value)
    return unless match_data

    new(**match_data.named_captures.symbolize_keys.transform_values { _1.presence&.to_i })
  end

  def self.from_value(value)
    case value
    when Hash
      new(**value)
    when Date, DateTime, Time
      from_date(value)
    when String
      from_string(value)
    else
      super
    end
  end

  def self.[](*)
    from_value(*)
  end

  def initialize(year: nil, month: nil, day: nil, weekday: nil, hour: nil, minute: nil) # rubocop:disable Metrics/ParameterLists,Metrics/AbcSize
    super({
      year: year.present? && year.to_i.abs,
      month: month.present? && (((month.to_i.abs - 1) % 12) + 1),
      day: day.present? && (((day.to_i.abs - 1) % 31) + 1),
      weekday: weekday.present? && (((weekday.to_i.abs - 1) % 7) + 1),
      hour: hour.present? && (hour.to_i.abs % 24),
      minute: minute.present? && (minute.to_i.abs % 60)
    })
  end

  def <=>(other)
    other = self.class.new(other) unless other.is_a?(self.class)
    deconstruct.zip(other.deconstruct).each do |(a, b)|
      result = a <=> b if a.present? && b.present?
      return result unless result.nil? || result.zero?
    end
    0
  end
end
