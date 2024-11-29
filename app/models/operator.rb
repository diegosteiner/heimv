# frozen_string_literal: true

# == Schema Information
#
# Table name: operators
#
#  id              :integer          not null, primary key
#  name            :string
#  email           :string
#  contact_info    :text
#  organisation_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  locale          :string           not null
#
# Indexes
#
#  index_operators_on_organisation_id  (organisation_id)
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
