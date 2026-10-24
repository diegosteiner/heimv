# frozen_string_literal: true

# == Schema Information
#
# Table name: calendar_labels
#
#  id                          :bigint           not null, primary key
#  color                       :string           not null
#  conflict_type_default       :integer
#  description_i18n            :jsonb            not null
#  discarded_at                :datetime
#  legend                      :boolean          default(TRUE), not null
#  title_i18n                  :jsonb            not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  booking_categories_id       :bigint
#  booking_category_default_id :bigint
#  organisation_id             :bigint
#
class CalendarLabel < ApplicationRecord
  COLOR_REGEX = /\A#(?:[0-9a-fA-F]{3,4}){1,2}\z/
  DEFAULT_COLORS = {
    pending: '#e8bc56',
    tentative: '#e8bc56',
    occupied: '#e85f5f',
    closed: '#929292',
    void: nil
  }.freeze

  extend Mobility
  include Discard::Model

  translates :title, :description, column_suffix: '_i18n', locale_accessors: true

  belongs_to :organisation, inverse_of: :calendar_labels
  belongs_to :booking_category_default, class_name: 'BookingCategory', optional: true
  has_many :occupancies, inverse_of: :calendar_label, dependent: :nullify

  scope :ordered, -> { order(color: :ASC) }
  enum :conflict_type_default, Occupancy::CONFLICT_TYPES, prefix: true

  validates :color, presence: true, format: { with: COLOR_REGEX }
  validates :title, presence: true
  validates :conflict_type_default, uniqueness: { scope: %i[organisation_id booking_category_default_id],
                                                  allow_blank: true },
                                    inclusion: { in: Occupancy::CONFLICT_TYPES.keys.map(&:to_s), allow_blank: true }

  def self.prepare_default(organisation, colors: {})
    CalendarLabel::DEFAULT_COLORS.merge(colors).filter_map do |conflict_type_default, color|
      next if color.nil?

      title_i18n = I18n.available_locales.index_with do |locale|
        I18n.t(conflict_type_default, scope: 'activerecord.enums.occupancy.conflict_type', locale:)
      end
      CalendarLabel.build(organisation:, title_i18n:, color:, conflict_type_default:)
    end
  end
end
