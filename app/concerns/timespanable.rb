# frozen_string_literal: true

module Timespanable
  extend ActiveSupport::Concern

  included do
    def past?(at = Time.zone.now)
      span&.end&.<(at)
    end

    def today?(date = Time.zone.today)
      begins_at = span.begin&.to_date
      ends_at = span.end&.to_date

      (begins_at..ends_at).cover?(date) if begins_at && ends_at
    end

    def span
      begins_at = send(self.class.timespan_begins_at_attribute)
      ends_at = send(self.class.timespan_ends_at_attribute)
      return if begins_at.blank? || ends_at.blank?

      begins_at..ends_at
    end

    def duration
      ActiveSupport::Duration.build(span.end - span.begin) if span
    end

    def nights
      (span.end.to_date - span.begin.to_date).to_i if span
    end
  end

  # rubocop:disable Metrics/BlockLength
  class_methods do
    attr_reader :timespan_begins_at_attribute, :timespan_ends_at_attribute

    def timespan(begins_at_attribute, ends_at_attribute)
      @timespan_begins_at_attribute = begins_at_attribute
      @timespan_ends_at_attribute = ends_at_attribute

      define_timespan_scopes

      validates timespan_begins_at_attribute, timespan_ends_at_attribute, presence: true
      validates timespan_ends_at_attribute, comparison: { greater_than_or_equal_to: timespan_begins_at_attribute },
                                            allow_blank: true
    end

    private

    def define_timespan_scopes
      scope :begins_at, timespan_scope_lambda(arel_table[timespan_begins_at_attribute])
      scope :ends_at, timespan_scope_lambda(arel_table[timespan_ends_at_attribute])
      scope :at, timespan_at_scope_lambda
      scope :future, timespan_future_scope_lambda
      scope :today, timespan_today_scope_lambda
    end

    def timespan_scope_lambda(arel_column)
      lambda do |before: nil, after: nil|
        where(arel_column.between(after..before)) if before.present? || after.present?
      end
    end

    def timespan_today_scope_lambda
      ->(at = Time.zone.today) { at(from: at.beginning_of_day, to: at.end_of_day) }
    end

    def timespan_future_scope_lambda
      -> { begins_at(after: Time.zone.now) }
    end

    def timespan_at_scope_lambda
      lambda do |from:, to:|
        begins_at(before: from).ends_at(after: to)
                               .or(begins_at(before: to, after: from))
                               .or(ends_at(before: to, after: from))
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
