# frozen_string_literal: true

module Validators
  class TimeRangeValidator < ActiveModel::EachValidator
    def validate_each(_record, _attributes, value)
      value ||= {}
      value.reverse_merge({})
      # validate on: :public_create do
      #   min = Time.zone.today.beginning_of_day
      #   errors.add(:begins_at, :too_far_in_past) if begins_at && begins_at < min
      #   errors.add(:ends_at, :too_far_in_past) if ends_at && ends_at < min
      # end
      # validate on: %i[public_create public_update] do
      #   max = organisation&.settings&.booking_window&.from_now
      #   next unless max

      #   errors.add(:begins_at, :too_far_in_future) if begins_at && begins_at > max
      #   errors.add(:ends_at, :too_far_in_future) if ends_at && ends_at > max
      # end
    end
  end
end
