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

    new(**match_data.named_captures.symbolize_keys.transform_values { _1.presence })
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

  def initialize(year: nil, month: nil, day: nil, weekday: nil, hour: nil, minute: nil) # rubocop:disable Metrics/ParameterLists
    super({
      year: initialize_datetime_part(year),
      month: initialize_datetime_part(month, 1, 12),
      day: initialize_datetime_part(day, 1, 31),
      weekday: initialize_datetime_part(weekday, 1, 7),
      hour: initialize_datetime_part(hour, 0, 24),
      minute: initialize_datetime_part(minute, 0, 60)
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

  def initialize_datetime_part(value, first = 0, last = nil)
    return if value.blank? || value == '*'

    value = value.to_i.abs - first
    value %= last if last.present?
    value + first
  end
end
