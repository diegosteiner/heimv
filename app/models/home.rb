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

class Home < Occupiable
  # has_many :bookings, inverse_of: :home

  belongs_to :organisation, inverse_of: :homes
  has_many :occupiables, inverse_of: :home, dependent: :nullify

  validates :ref, uniqueness: { scope: %i[organisation_id] }

  after_create { update(home: home || self) }

  def to_s
    name
  end

  def home
    self
  end

  def home_id
    id
  end

  def self_and_occupiable_ids
    [id, occupiable_ids].flatten.compact.uniq
  end
end
