# frozen_string_literal: true

# == Schema Information
#
# Table name: organisation_users
#
#  id              :bigint           not null, primary key
#  role            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_organisation_users_on_organisation_id              (organisation_id)
#  index_organisation_users_on_organisation_id_and_user_id  (organisation_id,user_id) UNIQUE
#  index_organisation_users_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#  fk_rails_...  (user_id => users.id)
#
class OrganisationUser < ApplicationRecord
  ROLES = %i[tenant admin manager readonly].freeze

  belongs_to :organisation, inverse_of: :organisation_users
  belongs_to :user, inverse_of: :organisation_users, autosave: true

  enum role: { none: 0, readonly: 1, manager: 2 }, _prefix: :role

  after_initialize :set_default_role, if: :new_record?

  validates :user, uniqueness: { scope: :organisation }
  validates :role, presence: true

  # def email
  #   user&.email
  # end

  def set_default_role
    self.role ||= :readonly
  end
end