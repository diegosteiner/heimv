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

  # validates :at, presence: true
  attribute :length

  def length=(duration)
    self.armed = duration.present? && !duration.zero?
    self.at = duration&.from_now unless duration&.zero?
  end

  def exceeded?(other = Time.zone.now)
    reload
    armed? && other > at
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

  def clear
    reload
    update_columns(armed: false) # rubocop:disable Rails/SkipsModelValidations
  end
end
