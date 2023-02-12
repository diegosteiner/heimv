# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                      :integer          not null, primary key
#  confirmation_sent_at    :datetime
#  confirmation_token      :string
#  confirmed_at            :datetime
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

  validates :email, presence: true
  validate do
    errors.add(:default_organisation_id, :invalid) if default_organisation && !in_organisation?(default_organisation)
  end

  def to_s
    email
  end

  def in_organisation(organisation)
    return if organisation.nil?

    organisation_users.find_by(organisation: organisation)
  end

  def in_organisation?(organisation)
    in_organisation(organisation).present?
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :invitable,
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :validatable
end
