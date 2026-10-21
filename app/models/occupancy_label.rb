# frozen_string_literal: true

# == Schema Information
#
# Table name: occupancy_labels
#
#  id                       :bigint           not null, primary key
#  color                    :string           not null
#  description_i18n         :jsonb            not null
#  occupancy_status_default :integer
#  title_i18n               :jsonb            not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  organisation_id          :bigint
#
class OccupancyLabel < ApplicationRecord
  COLOR_REGEX = /\A#(?:[0-9a-fA-F]{3,4}){1,2}\z/
  DEFAULT_COLORS = {
    pending: '#e8bc56',
    tentative: '#e8bc56',
    occupied: '#e85f5f',
    closed: '#929292',
    void: '#ffffff00'
  }.freeze

  extend Mobility
  include Discard::Model

  translates :title, :description, column_suffix: '_i18n', locale_accessors: true

  belongs_to :organisation, inverse_of: :occupancy_labels
  has_many :occupancies, inverse_of: :occupancy_label, dependent: :nullify

  scope :ordered, -> { order(color: :ASC) }
  enum :occupancy_status_default, Occupancy::STATUSES, prefix: true

  validates :color, presence: true, format: { with: COLOR_REGEX }
  validates :title, presence: true
  validates :occupancy_status_default, uniqueness: { scope: :organisation_id, allow_blank: true },
                                       inclusion: { in: Occupancy::STATUSES.keys.map(&:to_s), allow_blank: true }

  def self.create_default(organisation, defaults: {})
    OccupancyLabel::DEFAULT_COLORS.merge(override).map do |occupancy_status_default, color|
      title_i18n = I18n.available_locales.index_with do |locale|
        I18n.t(occupancy_status_default, scope: 'activerecord.enums.occupancy.occupancy_status', locale:)
      end
      OccupancyLabel.create(organisation:, title_i18n:, color:, occupancy_status_default:)
    end
  end
end
