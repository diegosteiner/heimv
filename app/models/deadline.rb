# == Schema Information
#
# Table name: deadlines
#
#  id               :bigint           not null, primary key
#  at               :datetime
#  booking_id       :uuid
#  responsible_type :string
#  responsible_id   :bigint
#  extendable       :integer          default(0)
#  current          :boolean          default(TRUE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  remarks          :text
#

class Deadline < ApplicationRecord
  belongs_to :booking, inverse_of: :deadlines
  # belongs_to :responsible, polymorphic: true, optional: true

  attribute :extended, default: false

  scope :ordered, -> { order(at: :desc) }
  scope :after, ->(at = Time.zone.now) { where(arel_table[:at].gteq(at)) }

  after_destroy :set_current, if: :current?
  after_save :set_current

  def exceeded?(other = Time.zone.now)
    other > at
  end

  def extend_until(extend_until)
    return unless extendable?

    update(at: extend_until, extendable: extendable - 1)
  end

  def extendable?
    extendable.positive?
  end

  def clear
    update(current: false)
  end

  def set_current
    last_deadlines = booking.deadlines.where(current: true).where.not(id: id)
    return unless !current || last_deadlines.exists?

    # rubocop:disable Rails/SkipsModelValidations
    last_deadlines.update_all(current: false)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def debug
    "##{id} #{at} #{created_at} #{current} #{remarks}"
  end
end
