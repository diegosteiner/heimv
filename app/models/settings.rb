# frozen_string_literal: true

class Settings
  include ActiveModel::Model
  include ActiveModel::Attributes

  def to_h
    attributes
  end

  def to_json(*)
    to_h.to_json(*)
  end

  class Type < ActiveModel::Type::Value
    attr_reader :settings_class

    def initialize(settings_class)
      super()
      @settings_class = settings_class
    end

    def defaults
      @defaults ||= settings_class.new.attributes.stringify_keys
    end

    def type
      :jsonb
    end

    def cast_value(value)
      case value
      when String
        return nil if value.blank?

        cast_value(ActiveSupport::JSON.decode(value))
      when Hash
        settings_class.new(value.stringify_keys.slice(*defaults.keys))
      when settings_class
        value
      end
    end

    def serialize(value)
      case value
      when Hash
        ActiveSupport::JSON.encode(value.stringify_keys.select { |k, v| defaults.key?(k) && defaults[k] != v })
      when settings_class
        serialize(value.to_h)
      else
        super
      end
    end

    def changed_in_place?(raw_old_value, new_value)
      cast_value(raw_old_value) != new_value
    end
  end
end
