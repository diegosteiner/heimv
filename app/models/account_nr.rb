class AccountNr
  attr_reader :parts

  def initialize(value); end

  def to_s
    return '' if parts.none?

    format('%<esr_mode>02d-%<id>d-%<checksum>1d', parts)
  end

  def to_code
    return '' if parts.none?

    format('%<esr_mode>02d%<id>06d%<checksum>1d', parts)
  end
end
