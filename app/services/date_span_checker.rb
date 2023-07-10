# frozen_string_literal: true

class DateSpanChecker
  REGEX = %r{\A
            ((?<begins_at_day>\d{1,2})\.(?<begins_at_month>\d{1,2})(\.(?<begins_at_year>\d{4})?)?)?
            -
            ((?<ends_at_day>\d{1,2})\.(?<ends_at_month>\d{1,2})(\.(?<ends_at_year>\d{4})?)?)?
          \z}x.freeze

  attr_reader :begins_at, :ends_at
  NullableDate = Struct.new(:year, :month, :day) do 
    def self.from_date(value)
      new(value.year, value.month, value.day)
    end
    
    def >=(other)
      self > other || self == other
    end

    def >(other)
      compare_year = year && other.year
      return year > other.year if compare_year && year != other.year

      compare_month = month && other.month 
      return month > other.month if compare_month && month != other.month

      compare_day = day && other.day 
      return day > other.day if compare_day && day != other.day
    
      false
    end

    def <(other)
      other > self
    end

    def <=(other)
      self < other || self == other
    end

    def ==(other)
      super ||
        ((!day || !other.day || day == other.day) &&
        (!month || !other.month || day == other.month) &&
        (!year || !other.year || day == other.year))
    end
  end

  def self.parse(value)
    new **REGEX.match(value).named_captures.symbolize_keys.transform_values { _1.presence&.to_i }
  end

  def initialize(**attrs)
    @begins_at = NullableDate.new(attrs[:begins_at_year], attrs[:begins_at_month], attrs[:begins_at_day])
    @ends_at = NullableDate.new(attrs[:ends_at_year], attrs[:ends_at_month], attrs[:ends_at_day])
  end

  def overlap?(other)
    case other 
    when NullableDate 
      begins_at <= other && ends_at >= other
    when Date, DateTime
      overlap?(NullableDate.from_date(other))
    when Range 
      overlap?(other.begin) || overlap?(other.end) || 
      (begins_at >= NullableDate.from_date(other.begin) && ends_at <= NullableDate.from_date(other.end))
    end
  end
end
