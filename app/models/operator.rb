# frozen_string_literal: true

# == Schema Information
#
# Table name: operators
#
#  id              :bigint           not null, primary key
#  contact_info    :text
#  email           :string
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_operators_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
class Operator < ApplicationRecord
  belongs_to :organisation, inverse_of: :operators
  has_many :operator_responsibilities, inverse_of: :operator, dependent: :destroy

  validates :email, format: Devise.email_regexp, allow_nil: true

  def to_s
    name
  end
end
