# frozen_string_literal: true

# == Schema Information
#
# Table name: operators
#
#  id              :bigint           not null, primary key
#  contact_info    :text
#  email           :string
#  locale          :string           not null
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
  locale_enum default: I18n.locale

  belongs_to :organisation, inverse_of: :operators
  has_many :operator_responsibilities, inverse_of: :operator, dependent: :destroy

  normalizes :email, with: ->(email) { email.present? ? EmailAddress.normal(email) : nil }

  validates :locale, presence: true
  validate do
    errors.add(:email, :invalid) unless email.nil? || EmailAddress.valid?(email)
  end

  def to_s
    name
  end
end
