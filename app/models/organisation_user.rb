# frozen_string_literal: true

# == Schema Information
#
# Table name: organisation_users
#
#  id              :integer          not null, primary key
#  organisation_id :integer          not null
#  user_id         :integer          not null
#  role            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  token           :string
#
# Indexes
#
#  index_organisation_users_on_organisation_id              (organisation_id)
#  index_organisation_users_on_organisation_id_and_user_id  (organisation_id,user_id) UNIQUE
#  index_organisation_users_on_user_id                      (user_id)
#

class OrganisationUser < ApplicationRecord
  belongs_to :organisation, inverse_of: :organisation_users
  belongs_to :user, inverse_of: :organisation_users, autosave: true

  enum :role, { none: 0, readonly: 1, admin: 2, manager: 3 }, prefix: :role

  has_secure_token :token, length: 48

  after_initialize :set_default_role, if: :new_record?

  validates :user, uniqueness: { scope: :organisation }
  validates :role, presence: true

  delegate :email, to: :user, allow_nil: true

  def set_default_role
    self.role ||= :readonly
  end

  def role?(*roles)
    roles.compact_blank.any? { role&.to_sym == _1.to_sym }
  end
end
