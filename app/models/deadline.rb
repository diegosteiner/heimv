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
# Indexes
#
#  index_deadlines_on_booking_id   (booking_id)
#  index_deadlines_on_responsible  (responsible_type,responsible_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

class Deadline < ApplicationRecord
  belongs_to :booking, inverse_of: :deadlines, touch: true

  scope :ordered, -> { order(at: :desc) }
  scope :armed, -> { where(armed: true) }
  scope :after, ->(at = Time.zone.now) { where(arel_table[:at].gteq(at)) }
  scope :next, -> { armed.ordered }

  # validates :at, presence: true
  attribute :length
  after_save :update_booking_deadline

  def length=(duration)
    self.armed = duration.present? && !duration.zero?
    self.at ||= duration&.from_now unless duration&.zero?
  end

  def exceeded?(other = Time.zone.now)
    armed? && other > at
  end

  def postponable_until
    postponable? && (at + postponable_for)
  end

  def postpone
    return unless postponable?

    update!(at: postponable_until, postponable_for: nil)
  end

  def postponable?
    postponable_for.present? && postponable_for.positive?
  end

  def clear
    update!(armed: false)
  end

  def update_booking_deadline
    booking.update_deadline!
  end
end
