class AccountNr
  attr_reader :parts

  def initialize(value)
    @parts = value.match(/(?<mode>\d{2})-(?<id>\d{3,6})-(?<checksum>\d)/)&.named_captures || {}
    @parts.transform_keys!(&:to_sym).transform_values!(&:to_i)
  end

  def to_s
    return '' if parts.none?

    format('%<mode>02d-%<id>d-%<checksum>1d', parts)
  end

  def to_code
    return '' if parts.none?

    format('%<mode>02d%<id>06d%<checksum>1d', parts)
  end
end
