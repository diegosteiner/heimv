# frozen_string_literal: true

class DurationType < ActiveModel::Type::Value
  REGEX = /^P(?!$)(\d+Y)?(\d+M)?(\d+W)?(\d+D)?(T(?=\d)(\d+H)?(\d+M)?(\d+S)?)?$/

  def type
    :string
  end

  def cast_value(value)
    case value
    when Integer
      ActiveSupport::Duration.build(value)
    when String
      return ActiveSupport::Duration.parse(value) if value =~ REGEX

      cast_value(value.to_i)
    when ActiveSupport::Duration
      value
    end
  end

  def serialize(value)
    case value
    when ActiveSupport::Duration
      value.to_i
    else
      super
    end
  end

  def changed_in_place?(raw_old_value, new_value)
    cast_value(raw_old_value) != new_value
  end
end
