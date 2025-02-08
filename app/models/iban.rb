# frozen_string_literal: true

class IBAN < IBANTools::IBAN
  delegate :to_liquid, :to_s, to: :prettify

  def to_sym
    @code&.to_sym
  end

  def valid?
    self.class.valid?(to_s)
  end

  def qrr?
    valid? && country_code.upcase == 'CH' && (30_000..31_999).cover?(numerify[0..4].to_i)
  end

  class Type < ActiveModel::Type::String
    def cast_value(value)
      return if value.blank?

      case value
      when String
        IBAN.new(value)
      when IBAN
        value
      end
    end

    def serialize(value)
      super(value&.to_s)
    end
  end
end
