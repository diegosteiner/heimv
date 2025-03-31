# frozen_string_literal: true

# == Schema Information
#
# Table name: organisation_users
#
#  id              :bigint           not null, primary key
#  role            :integer          not null
#  token           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#  user_id         :bigint           not null
#

class OrganisationUser < ApplicationRecord
  belongs_to :organisation, inverse_of: :organisation_users
  belongs_to :user, inverse_of: :organisation_users, autosave: true

  enum :role, { none: 0, readonly: 1, admin: 2, manager: 3, finance: 4 }, prefix: :role

  has_secure_token :token, length: 48

  after_initialize :set_default_role, if: :new_record?

  validates :user, uniqueness: { scope: :organisation }
  validates :role, presence: true

  delegate :email, to: :user, allow_nil: true

  def set_default_role
    self.role ||= :readonly
  end

  def role?(*roles)
    roles.compact_blank.any? { role&.to_sym == it.to_sym }
  end
end
