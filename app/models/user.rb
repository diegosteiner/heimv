# frozen_string_literal: true

class User < ApplicationRecord
  ROLES = %i[user admin].freeze
  enum role: ROLES
  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :invitable,
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
end
