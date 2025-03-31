# frozen_string_literal: true

# == Schema Information
#
# Table name: occupiables
#
#  id               :bigint           not null, primary key
#  description_i18n :jsonb            not null
#  discarded_at     :datetime
#  janitor          :text
#  name_i18n        :jsonb            not null
#  occupiable       :boolean          default(FALSE)
#  ordinal          :integer
#  ref              :string
#  settings         :jsonb
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  home_id          :bigint
#  organisation_id  :bigint           not null
#

class Occupiable < ApplicationRecord
  include RankedModel
  include Discard::Model
  extend Mobility

  has_many :occupancies, -> { ordered }, inverse_of: :occupiable, dependent: :restrict_with_error

  belongs_to :organisation, inverse_of: :occupiables
  belongs_to :home, inverse_of: :occupiables, optional: true

  attribute :settings, OccupiableSettings.to_type, default: -> { OccupiableSettings.new }

  translates :name, :description, column_suffix: '_i18n', locale_accessors: true
  ranks :ordinal, with_same: :organisation_id, class_name: 'Occupiable'
  normalizes :ref, with: -> { it.presence&.strip }

  scope :occupiable, -> { where(occupiable: true) }
  scope :ordered, -> { rank(:ordinal) }

  validates :name, presence: true
  validates :ref, uniqueness: { scope: :organisation }
  validates :type, inclusion: { in: %w[Home Occupiable] }, allow_nil: true

  def to_s
    name
  end

  def cover_image_url; end
end
