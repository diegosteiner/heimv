# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  organisation_id        :bigint
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_organisation_id       (organisation_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class User < ApplicationRecord
  PERMISSIONS = %i[tenant admin manager readonly].freeze

  belongs_to :organisation, optional: true

  enum role: PERMISSIONS, _prefix: :role

  after_initialize :set_default_role, if: :new_record?

  validates :organisation, presence: true, unless: :role_admin?
  validates :role, :email, presence: true

  def set_default_role
    self.role ||= :readonly
  end

  def to_s
    email
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :invitable,
  devise :database_authenticatable, :recoverable, :rememberable, :validatable
end
