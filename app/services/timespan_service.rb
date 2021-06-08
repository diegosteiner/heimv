# frozen_string_literal: true

class TimespanService
  TOKENS = {
    's' => 1,
    'm' => 60,
    'h' => (60 * 60),
    'd' => (60 * 60 * 24),
    'w' => (60 * 60 * 24 * 7)
  }.freeze

  def self.parse(input)
    return unless input
    return input if input.is_a?(Integer)

    input.scan(/(\d+)(\w)/).reduce(0) do |seconds, (amount, measure)|
      seconds + amount.to_i * TOKENS[measure]
    end
  end
end
