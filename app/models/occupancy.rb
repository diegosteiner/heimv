# frozen_string_literal: true

# == Schema Information
#
# Table name: occupancies
#
#  id             :uuid             not null, primary key
#  begins_at      :datetime         not null
#  color          :string
#  ends_at        :datetime         not null
#  occupancy_type :integer          default("free"), not null
#  remarks        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  booking_id     :uuid
#  home_id        :bigint           not null
#
# Indexes
#
#  index_occupancies_on_begins_at       (begins_at)
#  index_occupancies_on_ends_at         (ends_at)
#  index_occupancies_on_home_id         (home_id)
#  index_occupancies_on_occupancy_type  (occupancy_type)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#

class Occupancy < ApplicationRecord
  COLOR_REGEX = /\A#(?:[0-9a-fA-F]{3,4}){1,2}\z/
  OCCUPANCY_TYPES = { free: 0, tentative: 1, occupied: 2, closed: 3 }.freeze

  include Timespanable

  timespan :begins_at, :ends_at
  belongs_to :home
  belongs_to :booking, inverse_of: :occupancies, optional: true, touch: true

  has_one :organisation, through: :home

  enum occupancy_type: OCCUPANCY_TYPES

  scope :ordered, -> { order(begins_at: :ASC) }
  scope :blocking, -> { where(occupancy_type: %i[tentative occupied closed]) }

  before_validation :sync_with_booking
  validates :color, format: { with: COLOR_REGEX }, allow_blank: true

  def to_s
    "#{I18n.l(begins_at, format: :short)} - #{I18n.l(ends_at, format: :short)}"
  end

  def conflicting(margin = 0)
    return if begins_at.blank? || ends_at.blank? || home.blank?

    margin ||= 0
    home.occupancies.at(from: begins_at - margin, to: ends_at + margin).blocking.where.not(id: id)
  end

  def color=(value)
    super(value.presence) if value != color
  end

  def color
    super.presence || booking&.color
  end

  def sync_with_booking 
    return if booking.blank?

    assign_attributes(begins_at: booking.begins_at, ends_at: booking.ends_at,
                      occupancy_type: booking.occupancy_type)
    end
end
