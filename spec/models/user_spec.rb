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

# describe User do
# end
