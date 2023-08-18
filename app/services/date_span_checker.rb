# frozen_string_literal: true

class DateSpanChecker
  REGEX = /\A
            (?:(?<begins_at_day>\d{1,2})\.(?<begins_at_month>\d{1,2})(?:\.(?<begins_at_year>\d{4})?)?)?
            -
            (?:(?<ends_at_day>\d{1,2})\.(?<ends_at_month>\d{1,2})(?:\.(?<ends_at_year>\d{4})?)?)?
          \z/x

  attr_reader :begins_at, :ends_at

  NullableDate = Struct.new(:year, :month, :day) do
    def self.from_date(value)
      new(value.year, value.month, value.day)
    end

    def >=(other)
      self > other || self == other
    end

    def <(other)
      return self.class.from_date(other.to_date) > self if other.respond_to?(:to_date)

      other > self
    end

    def <=(other)
      self < other || self == other
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def >(other)
      return self > self.class.from_date(other.to_date) if other.respond_to?(:to_date)

      compare_year = year && other.year
      return year > other.year if compare_year && year != other.year

      compare_month = month && other.month
      return month > other.month if compare_month && month != other.month

      compare_day = day && other.day
      day > other.day if compare_day && day != other.day
    end

    def ==(other)
      return self == self.class.from_date(other.to_date) if other.respond_to?(:to_date)

      super ||
        ((!day || !other.day || day == other.day) &&
        (!month || !other.month || day == other.month) &&
        (!year || !other.year || day == other.year))
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end

  def self.parse(value)
    match_data = REGEX.match(value)
    return unless match_data

    new(**match_data.named_captures.symbolize_keys.transform_values { _1.presence&.to_i })
  end

  def initialize(**attrs)
    @begins_at = NullableDate.new(attrs[:begins_at_year], attrs[:begins_at_month], attrs[:begins_at_day])
    @ends_at = NullableDate.new(attrs[:ends_at_year], attrs[:ends_at_month], attrs[:ends_at_day])
  end

  def overlap?(other)
    case other
    when NullableDate, Date, DateTime, ActiveSupport::TimeWithZone
      begins_at <= other.to_date && ends_at >= other.to_date
    when Range
      overlap?(other.begin) || overlap?(other.end) || (begins_at >= other.begin && ends_at <= other.end)
    end
  end
end
