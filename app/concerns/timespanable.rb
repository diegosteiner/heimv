# frozen_string_literal: true

module Timespanable
  extend ActiveSupport::Concern

  # included do
  #   scope :disabled, -> { where(disabled: true) }

  # end

  # rubocop:disable Metrics/BlockLength
  class_methods do
    def timespan(begins_at_attribute, ends_at_attribute)
      @timespan_begins_at_attribute = begins_at_attribute
      @timespan_ends_at_attribute = ends_at_attribute

      # TODO: remove when getting rid of multiparam attributes
      date_time_attribute begins_at_attribute, timezone: Time.zone.name
      date_time_attribute ends_at_attribute, timezone: Time.zone.name

      define_timespan_scopes
    end

    private

    def define_timespan_scopes
      scope :begins_at, timespan_scope_lambda(arel_table[@timespan_begins_at_attribute])
      scope :ends_at, timespan_scope_lambda(arel_table[@timespan_ends_at_attribute])
      scope :at, timespan_at_scope_lambda
      scope :future, timespan_future_scope_lambda
      scope :today, timespan_today_scope_lambda
    end

    def timespan_scope_lambda(arel_column)
      lambda do |before: nil, after: nil|
        return where(arel_column.between(after..before)) if before.present? && after.present?
        return where(arel_column.gt(after)) if after.present?
        return where(arel_column.lt(before)) if before.present?
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
