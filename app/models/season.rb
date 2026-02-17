# frozen_string_literal: true

# == Schema Information
#
# Table name: seasons
#
#  id                          :bigint           not null, primary key
#  begins_at                   :datetime         not null
#  discarded_at                :datetime
#  ends_at                     :datetime         not null
#  label_i18n                  :jsonb
#  max_bookings                :integer
#  max_occupied_days           :integer
#  public_occupancy_visibility :integer          not null
#  status                      :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  organisation_id             :bigint           not null
#
class Season < ApplicationRecord
  include Timespanable
  include Discard::Model
  extend Mobility

  translates :label, column_suffix: '_i18n', locale_accessors: true

  belongs_to :organisation, inverse_of: :seasons
  has_many :bookings, inverse_of: :season, dependent: :nullify

  enum :status, { private: 0, open: 1, closed: 2 }, prefix: true
  flag :public_occupancy_visibility, Occupancy::OCCUPANCY_TYPES.keys

  scope :ordered, -> { order(begins_at: :ASC) }

  validates :begins_at, :ends_at, presence: true
  validate do
    next unless begins_at.present? && ends_at.present?

    errors.add(:base, :conflicting) if conflicting.exists?
  end

  def conflicting
    organisation.seasons.kept.at(from: begins_at, to: ends_at)
                .where.not(id:).where.not(begins_at: ends_at).where.not(ends_at: begins_at)
  end
end
