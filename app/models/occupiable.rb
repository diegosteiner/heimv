# frozen_string_literal: true

# == Schema Information
#
# Table name: occupiables
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(FALSE)
#  description     :text
#  discarded_at    :datetime
#  janitor         :text
#  name            :string
#  occupiable      :boolean          default(FALSE)
#  ordinal         :integer
#  ref             :string
#  settings        :jsonb
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  home_id         :bigint
#  organisation_id :bigint           not null
#
# Indexes
#
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

  has_many :occupancies, inverse_of: :occupiable, dependent: :restrict_with_error

  belongs_to :organisation, inverse_of: :occupiables
  belongs_to :home, inverse_of: :occupiables, optional: true

  attribute :settings, Settings::Type.new(OccupiableSettings), default: -> { OccupiableSettings.new }

  scope :ordered, -> { order(name: :ASC) }
  scope :occupiable, -> { where(occupiable: true) }
  scope :active, -> { where(active: true) }
  scope :ordered, -> { rank(:ordinal) }

  ranks :ordinal, with_same: :organisation_id

  validates :name, presence: true
  validates :type, inclusion: { in: %w[Home Occupiable] }, allow_nil: true

  def to_s
    name
  end

  def cover_image_url; end
end
