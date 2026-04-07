# frozen_string_literal: true

# == Schema Information
#
# Table name: deadlines
#
#  id               :bigint           not null, primary key
#  armed            :boolean          default(TRUE)
#  at               :datetime
#  postponable_for  :integer          default(0)
#  remarks          :text
#  responsible_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  booking_id       :uuid
#  responsible_id   :bigint
#

class Deadline < ApplicationRecord
  belongs_to :booking, inverse_of: :deadline, touch: false # don't touch booking, as it will trigger state updates

  scope :ordered, -> { order(at: :desc) }
  scope :armed, -> { where(armed: true) }
  scope :after, ->(at = Time.zone.now) { where(arel_table[:at].gteq(at)) }
  scope :next, -> { armed.ordered }

  validates :at, presence: true, if: :armed
  before_validation :set_at

  def set_at # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
    return unless at_changed? || new_record?

    now = Time.zone.now
    value = at
    value = booking&.organisation&.deadline_settings&.try(value) if value.is_a?(Symbol)
    value = value.seconds if value.is_a?(Integer)
    value = now + value if value.is_a?(ActiveSupport::Duration)

    self.at = value
    self.armed = value.present? && !(value - now).negative? unless armed_changed?
  end

  def exceeded?(other = Time.zone.now)
    reload
    at && armed? && other > at
  end

  def postponable_until
    postponable? && (at + postponable_for)
  end

  def postpone
    return unless postponable?

    update(at: postponable_until, postponable_for: nil) && booking.touch # rubocop:disable Rails/SkipsModelValidations
  end

  def postponable?
    postponable_for.present? && postponable_for.positive? && armed?
  end

  def clear!
    update_columns(armed: false) # rubocop:disable Rails/SkipsModelValidations
  end

  def arm!
    update_columns(armed: true) # rubocop:disable Rails/SkipsModelValidations
  end
end
