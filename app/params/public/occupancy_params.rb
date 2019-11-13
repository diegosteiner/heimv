# frozen_string_literal: true

module Public
  class OccupancyParams < ApplicationParams
    def self.permitted_keys
      %i[begins_at begins_at_time begins_at_date ends_at ends_at_time ends_at_date]
    end

    sanitize do |params|
      params.merge(
        begins_at_time: [
          params.delete('begins_at_time(4i)'),
          params.delete('begins_at_time(5i)')
        ].compact.join(':'),
        ends_at_time: [
          params.delete('ends_at_time(4i)'),
          params.delete('ends_at_time(5i)')
        ].compact.join(':')
      )
    end
  end
end
