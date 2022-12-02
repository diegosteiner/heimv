# frozen_string_literal: true

# == Schema Information
#
# Table name: homes
#
#  id               :bigint           not null, primary key
#  address          :text
#  janitor          :text
#  name             :string
#  ref              :string
#  requests_allowed :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_homes_on_organisation_id          (organisation_id)
#  index_homes_on_ref_and_organisation_id  (ref,organisation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class Home < ApplicationRecord
  has_many :occupancies, dependent: :destroy
  has_many :bookings, dependent: :restrict_with_error
  has_many :tarifs, -> { ordered }, dependent: :destroy, inverse_of: :home
  has_many :meter_reading_periods, -> { ordered }, through: :tarifs, inverse_of: :home, dependent: :destroy
  has_many :rich_text_templates, inverse_of: :home, dependent: :destroy
  has_many :operator_responsibilities, inverse_of: :home, dependent: :destroy
  has_many :designated_documents, dependent: :destroy, inverse_of: :home

  belongs_to :organisation, inverse_of: :homes

  scope :ordered, -> { order(name: :ASC) }

  validates :name, presence: true
  validates :ref, uniqueness: { scope: %i[organisation_id] }

  def to_s
    name
  end

  def cover_image_url; end
end
