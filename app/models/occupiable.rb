# frozen_string_literal: true

# == Schema Information
#
# Table name: occupiables
#
#  id               :bigint           not null, primary key
#  description_i18n :jsonb
#  discarded_at     :datetime
#  janitor          :text
#  name_i18n        :jsonb
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
# Indexes
#
#  index_occupiables_on_discarded_at             (discarded_at)
#  index_occupiables_on_home_id                  (home_id)
#  index_occupiables_on_organisation_id          (organisation_id)
#  index_occupiables_on_ref_and_organisation_id  (ref,organisation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
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
  normalizes :ref, with: -> { _1.presence&.strip }

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
