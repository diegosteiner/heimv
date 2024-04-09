# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                      :integer          not null, primary key
#  confirmation_sent_at    :datetime
#  confirmation_token      :string
#  confirmed_at            :datetime
#  default_calendar_view   :integer
#  email                   :string           default(""), not null
#  encrypted_password      :string           default(""), not null
#  invitation_accepted_at  :datetime
#  invitation_created_at   :datetime
#  invitation_limit        :integer
#  invitation_sent_at      :datetime
#  invitation_token        :string
#  invitations_count       :integer          default(0)
#  invited_by_type         :string
#  remember_created_at     :datetime
#  reset_password_sent_at  :datetime
#  reset_password_token    :string
#  role_admin              :boolean          default(FALSE)
#  token                   :string
#  unconfirmed_email       :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  default_organisation_id :bigint
#  invited_by_id           :bigint
#
# Indexes
#
#  index_users_on_default_organisation_id  (default_organisation_id)
#  index_users_on_email                    (email) UNIQUE
#  index_users_on_invitation_token         (invitation_token) UNIQUE
#  index_users_on_invited_by               (invited_by_type,invited_by_id)
#  index_users_on_invited_by_id            (invited_by_id)
#  index_users_on_reset_password_token     (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (default_organisation_id => organisations.id)
#

class User < ApplicationRecord
  belongs_to :default_organisation, optional: true, class_name: 'Organisation'
  has_many :organisation_users, dependent: :destroy
  has_many :organisations, through: :organisation_users
  has_many :booking_logs, inverse_of: :user, dependent: :destroy, class_name: 'Booking::Log'

  enum default_calendar_view: { months: 0, year: 1 }
  has_secure_token :token, length: 48

  normalizes :email, with: ->(email) { email.present? && EmailAddress.normal(email) }

  validates :email, presence: true
  validates :token, length: { minimum: 48 }, allow_nil: true
  validate do
    errors.add(:default_organisation_id, :invalid) if default_organisation && !in_organisation?(default_organisation)
    errors.add(:email, :invalid) unless email.nil? || EmailAddress.valid?(email)
  end

  def to_s
    email
  end

  def in_organisation(organisation)
    return if organisation.nil?

    organisation_users.find_by(organisation:)
  end

  def in_organisation?(organisation)
    in_organisation(organisation).present?
  end

  def self.find_by_token(token, organisation)
    return nil unless token.present? && organisation.present?

    organisation.users.find_by(token:, role_admin: false)
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :invitable,
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :validatable
end
