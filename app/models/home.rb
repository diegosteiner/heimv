# frozen_string_literal: true

# == Schema Information
#
# Table name: occupiables
#
#  id              :bigint           not null, primary key
#  bookable        :boolean          default(FALSE)
#  description     :text
#  janitor         :text
#  name            :string
#  occupiable      :boolean          default(FALSE)
#  ref             :string
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

class Home < Occupiable
  # has_many :bookings, inverse_of: :home

  belongs_to :organisation, inverse_of: :homes
  has_many :occupiables, inverse_of: :home, dependent: :nullify

  validates :ref, uniqueness: { scope: %i[organisation_id] }

  def to_s
    name
  end
end
